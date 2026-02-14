#!/usr/bin/env bash
set -euo pipefail

BASE_SHA="${1:-}"
HEAD_SHA="${2:-}"

if [[ -z "$BASE_SHA" || -z "$HEAD_SHA" ]]; then
  echo "Error: base-sha and head-sha inputs are required."
  echo "Provide them from your workflow, for example:"
  echo "  base-sha: \${{ github.event.pull_request.base.sha }}"
  echo "  head-sha: \${{ github.event.pull_request.head.sha }}"
  exit 1
fi

echo "Checking commits between $BASE_SHA and $HEAD_SHA"

# Conventional Commits types (lowercase as per spec)
TYPES="feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert"

COMMITS=$(git log --no-merges --format=%H "$BASE_SHA..$HEAD_SHA")

EXIT_CODE=0
INVALID_COUNT=0
VALID_COUNT=0

echo "-----------------------------------------------------"
echo "Validating commit messages..."
echo "-----------------------------------------------------"

for COMMIT in $COMMITS; do
  MESSAGE=$(git log --format=%B -n 1 "$COMMIT" | head -n 1)
  COMMIT_SHORT=$(echo "$COMMIT" | cut -c1-7)

  if ! echo "$MESSAGE" | grep -qE "^($TYPES)(\([^)]+\))?!?: .+"; then
    echo "INVALID $COMMIT_SHORT: $MESSAGE"
    INVALID_COUNT=$((INVALID_COUNT + 1))
    EXIT_CODE=1
  else
    echo "VALID $COMMIT_SHORT: $MESSAGE"
    VALID_COUNT=$((VALID_COUNT + 1))
  fi
done

echo ""
echo "-----------------------------------------------------"
echo "Summary: $VALID_COUNT valid, $INVALID_COUNT invalid"
echo "-----------------------------------------------------"

if [[ $EXIT_CODE -ne 0 ]]; then
  echo ""
  echo "Invalid commit message format detected."
  echo ""
  echo "Conventional Commits Specification:"
  echo "  Format: <type>[optional scope][optional !]: <description>"
  echo ""
  echo "  Types: $TYPES"
  echo "  Scope: optional, e.g., (api), (SLM-1234), (Dashboard)"
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
