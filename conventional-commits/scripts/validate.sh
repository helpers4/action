#!/usr/bin/env bash
# This file is part of helpers4.
# Copyright (C) 2026 helpers4
# SPDX-License-Identifier: AGPL-3.0-or-later
set -euo pipefail

# Read inputs from environment variables
BASE_SHA="${INPUT_BASE_SHA:-}"
HEAD_SHA="${INPUT_HEAD_SHA:-}"
TYPES="${INPUT_TYPES:-feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert}"
SCOPES="${INPUT_SCOPES:-}"
REQUIRE_SCOPE="${INPUT_REQUIRE_SCOPE:-false}"
IGNORE_COMMITS="${INPUT_IGNORE_COMMITS:-}"
VALIDATE_PR_TITLE="${INPUT_VALIDATE_PR_TITLE:-false}"
PR_COMMENT="${INPUT_PR_COMMENT:-error}"

if [[ -z "$BASE_SHA" || -z "$HEAD_SHA" ]]; then
  if [[ -z "$BASE_SHA" ]]; then
    BASE_REF=""
    if [[ -n "${GITHUB_BASE_REF:-}" ]] && git show-ref --verify --quiet "refs/remotes/origin/$GITHUB_BASE_REF"; then
      BASE_REF="origin/$GITHUB_BASE_REF"
    elif git show-ref --verify --quiet "refs/remotes/origin/main"; then
      BASE_REF="origin/main"
    elif git show-ref --verify --quiet "refs/remotes/origin/master"; then
      BASE_REF="origin/master"
    fi

    if [[ -n "$BASE_REF" ]]; then
      BASE_SHA=$(git merge-base "$BASE_REF" HEAD)
    fi
  fi

  if [[ -z "$HEAD_SHA" ]]; then
    HEAD_SHA=$(git rev-parse HEAD)
  fi
fi

if [[ -z "$BASE_SHA" || -z "$HEAD_SHA" ]]; then
  echo "Error: base-sha and head-sha are required or must be derivable from Git refs."
  echo "Provide them from your workflow, for example:"
  echo "  base-sha: \${{ github.event.pull_request.base.sha }}"
  echo "  head-sha: \${{ github.event.pull_request.head.sha }}"
  exit 1
fi

echo "Checking commits between $BASE_SHA and $HEAD_SHA"

# Build scope validation regex if scopes are specified
SCOPE_PATTERN=""
if [[ -n "$SCOPES" ]]; then
  SCOPE_PATTERN="($SCOPES)"
fi

# Build commit pattern
if [[ "$REQUIRE_SCOPE" == "true" ]]; then
  # Scope is required
  if [[ -n "$SCOPE_PATTERN" ]]; then
    COMMIT_PATTERN="^($TYPES)\($SCOPE_PATTERN\)!?: .+"
  else
    COMMIT_PATTERN="^($TYPES)\([^)]+\)!?: .+"
  fi
else
  # Scope is optional
  if [[ -n "$SCOPE_PATTERN" ]]; then
    COMMIT_PATTERN="^($TYPES)(\($SCOPE_PATTERN\))?!?: .+"
  else
    COMMIT_PATTERN="^($TYPES)(\([^)]+\))?!?: .+"
  fi
fi

COMMITS=$(git log --no-merges --format=%H "$BASE_SHA..$HEAD_SHA")

EXIT_CODE=0
INVALID_COUNT=0
VALID_COUNT=0
INVALID_COMMITS=""
ERROR_DETAILS=""

echo "-----------------------------------------------------"
echo "Validating commit messages..."
echo "Pattern: $COMMIT_PATTERN"
echo "-----------------------------------------------------"

for COMMIT in $COMMITS; do
  MESSAGE=$(git log --format=%B -n 1 "$COMMIT" | head -n 1)
  COMMIT_SHORT=$(echo "$COMMIT" | cut -c1-7)

  # Check if commit should be ignored
  SHOULD_IGNORE=false
  if [[ -n "$IGNORE_COMMITS" ]]; then
    while IFS= read -r PATTERN; do
      if [[ -n "$PATTERN" ]] && echo "$MESSAGE" | grep -qE "$PATTERN"; then
        SHOULD_IGNORE=true
        echo "⏭️  IGNORED $COMMIT_SHORT: $MESSAGE"
        break
      fi
    done <<< "$IGNORE_COMMITS"
  fi

  if [[ "$SHOULD_IGNORE" == "true" ]]; then
    continue
  fi

  if ! echo "$MESSAGE" | grep -qE "$COMMIT_PATTERN"; then
    echo "❌ INVALID $COMMIT_SHORT: $MESSAGE"
    INVALID_COUNT=$((INVALID_COUNT + 1))
    INVALID_COMMITS="$INVALID_COMMITS- \`$COMMIT_SHORT\`: $MESSAGE"$'\n'
    ERROR_DETAILS="$ERROR_DETAILS$MESSAGE|"
    EXIT_CODE=1
  else
    echo "✅ VALID $COMMIT_SHORT: $MESSAGE"
    VALID_COUNT=$((VALID_COUNT + 1))
  fi
done

echo ""
echo "-----------------------------------------------------"
echo "Summary: $VALID_COUNT valid, $INVALID_COUNT invalid"
echo "-----------------------------------------------------"

# Validate PR title if requested
if [[ "$VALIDATE_PR_TITLE" == "true" && -n "${GITHUB_EVENT_PATH:-}" ]]; then
  PR_TITLE=$(jq -r '.pull_request.title // empty' "$GITHUB_EVENT_PATH" 2>/dev/null || echo "")
  
  if [[ -n "$PR_TITLE" ]]; then
    echo ""
    echo "Validating PR title..."
    if ! echo "$PR_TITLE" | grep -qE "$COMMIT_PATTERN"; then
      echo "❌ INVALID PR TITLE: $PR_TITLE"
      INVALID_COUNT=$((INVALID_COUNT + 1))
      INVALID_COMMITS="$INVALID_COMMITS- **PR Title**: $PR_TITLE"$'\n'
      ERROR_DETAILS="$ERROR_DETAILS$PR_TITLE"
      EXIT_CODE=1
    else
      echo "✅ VALID PR TITLE: $PR_TITLE"
    fi
  fi
fi

# Set GitHub Actions outputs
if [[ -n "${GITHUB_OUTPUT:-}" ]]; then
  if [[ $EXIT_CODE -eq 0 ]]; then
    echo "status=success" >> "$GITHUB_OUTPUT"
  else
    echo "status=failure" >> "$GITHUB_OUTPUT"
  fi
  echo "invalid-count=$INVALID_COUNT" >> "$GITHUB_OUTPUT"
  echo "valid-count=$VALID_COUNT" >> "$GITHUB_OUTPUT"
  
  # Clean error details for output
  ERROR_MSG="${ERROR_DETAILS%|}"
  echo "error-message=$ERROR_MSG" >> "$GITHUB_OUTPUT"
fi

# Determine if we should post to PR
SHOULD_POST_PR=0
case "$PR_COMMENT" in
  none|false)
    SHOULD_POST_PR=0
    ;;
  error)
    [[ $EXIT_CODE -ne 0 ]] && SHOULD_POST_PR=1
    ;;
  success)
    [[ $EXIT_CODE -eq 0 ]] && SHOULD_POST_PR=1
    ;;
  both|true)
    SHOULD_POST_PR=1
    ;;
esac

# Post comment to PR if needed
if [[ $SHOULD_POST_PR -eq 1 && -n "${GITHUB_TOKEN:-}" && -n "${GITHUB_REPOSITORY:-}" && -n "${GITHUB_EVENT_PATH:-}" ]]; then
  PR_NUMBER=$(jq -r '.pull_request.number // empty' "$GITHUB_EVENT_PATH" 2>/dev/null || echo "")
  
  if [[ -n "$PR_NUMBER" ]]; then
    # Prepare comment based on validation result
    if [[ $EXIT_CODE -ne 0 ]]; then
      # Build scope info
      SCOPE_INFO=""
      if [[ "$REQUIRE_SCOPE" == "true" ]]; then
        SCOPE_INFO=" (scope required)"
      fi
      if [[ -n "$SCOPES" ]]; then
        SCOPE_INFO="$SCOPE_INFO
**Allowed scopes:** \`$SCOPES\`"
      fi

      COMMENT_BODY="⚠️ **Conventional Commits Validation Failed**

❌ Found $INVALID_COUNT commit(s) with invalid message format:

$INVALID_COMMITS
**Format:** \`<type>[optional scope][optional !]: <description>\`

**Valid types:** $TYPES$SCOPE_INFO

**Examples:**
- \`feat: add new feature\`
- \`feat(api): add new endpoint\`
- \`fix(SLM-1234): resolve bug\`
- \`feat(scope)!: breaking change\`

📖 Learn more: https://www.conventionalcommits.org/"
    else
      COMMENT_BODY="✅ **Conventional Commits Validation Passed**

All $VALID_COUNT commit(s) follow the Conventional Commits specification!

📖 Learn more: https://www.conventionalcommits.org/"
    fi

    # API call to post PR comment
    curl -s -X POST \
      -H "Authorization: token $GITHUB_TOKEN" \
      -H "Accept: application/vnd.github.v3+json" \
      "https://api.github.com/repos/$GITHUB_REPOSITORY/issues/$PR_NUMBER/comments" \
      -d "{\"body\":$(echo "$COMMENT_BODY" | jq -Rs '.')}" > /dev/null
  fi
fi

if [[ $EXIT_CODE -ne 0 ]]; then
  echo ""
  echo "Invalid commit message format detected."
  echo ""
  echo "Conventional Commits Specification:"
  echo "  Format: <type>[optional scope][optional !]: <description>"
  echo ""
  echo "  Types: $TYPES"
  if [[ -n "$SCOPES" ]]; then
    echo "  Allowed Scopes: $SCOPES"
  else
    echo "  Scope: optional, e.g., (api), (SLM-1234), (Dashboard)"
  fi
  if [[ "$REQUIRE_SCOPE" == "true" ]]; then
    echo "  Note: Scope is REQUIRED"
  fi
  echo "  !: optional breaking change indicator"
  echo ""
  echo "Valid examples:"
  echo "  - feat: add new feature"
  echo "  - feat(api): add new endpoint"
  echo "  - feat!: breaking change"
  echo "  - feat(scope)!: breaking change with scope"
  echo "  - chore!: update dependencies"
  echo "  - fix(SLM-1234): resolve bug"
  echo ""
  echo "How to fix:"
  echo "  - Reword commits: git rebase -i $BASE_SHA"
  echo "  - Change commit message to match format above"
  echo "  - Force push: git push --force-with-lease"
  echo ""
  echo "Documentation: https://www.conventionalcommits.org/"
fi

exit $EXIT_CODE
