# AGENTS.md - GitHub Actions

## ⛔ CRITICAL RESTRICTIONS

- **NEVER execute `git push`** - The user will push manually after review
- **NEVER use GPT models** - Use Claude models only (claude-sonnet-4, Claude Opus 4.5)
- **Everything in English** - Code, comments, commits, documentation, logs, PR descriptions

## Organization Context

**helpers4** is a collection of open-source utilities across 5 repos: `typescript`, `devcontainer`, `action` (this repo), `website`, `.github`. All licensed LGPL-3.0.

## Commit Messages

Follow [Conventional Commits](https://www.conventionalcommits.org/) with a gitmoji between the scope and the description.

**Format:** `<type>(<scope>): <emoji> <description>`

**Scopes:** conventional-commits, CI-CD

| Type | Primary | Alternatives (gitmoji.dev) | When to use |
|------|---------|---------------------------|-------------|
| feat | ✨ | 🚸 UX, ♿️ a11y, 🌐 i18n, 💬 text/literals | New feature |
| fix | 🐛 | 🚑️ hotfix, 🔒️ security, 🩹 trivial, 🥅 errors, 🚨 warnings, ✏️ typo | Bug fix |
| docs | 📝 | 💡 source comments, 📄 license | Documentation |
| refactor | ♻️ | 🎨 structure, 🔥 remove code, ⚰️ dead code, 🚚 move/rename | Code refactoring |
| test | ✅ | 🧪 failing test, 💚 fix CI test | Tests |
| chore | 🔧 | 🙈 gitignore, 🔖 tag/release, 📌 pin deps, 🩺 healthcheck | Maintenance |
| perf | ⚡️ | — | Performance |
| style | 💄 | 🎨 code style | Code style / UI |
| ci | 👷 | 💚 fix CI | CI/CD |
| build | 📦️ | ➕ add dep, ➖ remove dep, ⬆️ upgrade dep, ⬇️ downgrade dep | Build system |
| revert | ⏪️ | — | Revert |

> Pick the **most specific** gitmoji that matches the change. The primary is the safe default; reach for an alternative when it adds real signal. Full list: https://gitmoji.dev

**Examples:**
- `feat(conventional-commits): ✨ add PR title validation`
- `fix(CI-CD): 🐛 fix checkout depth`
- `docs: 📝 update usage examples`

---

## This Repository

**Purpose:** Reusable GitHub Actions for the helpers4 organization and external users.

### Project Structure

```
action/
├── conventional-commits/
│   ├── action.yml              # Action metadata and inputs
│   ├── README.md               # Usage documentation
│   └── scripts/
│       └── validate.sh         # Main validation logic
├── AGENTS.md                   # This file
├── LICENSE                     # LGPL-3.0
└── README.md
```

### Conventional Commits Action

**Type:** Composite action (Bash)

**Inputs:**
| Input | Default | Description |
|-------|---------|-------------|
| `checkout` | `true` | Run actions/checkout |
| `base-sha` | — | Base commit SHA |
| `head-sha` | — | Head commit SHA |
| `types` | `feat\|fix\|docs\|...` | Allowed commit types (pipe-separated regex) |
| `scopes` | — | Allowed scopes (pipe-separated regex) |
| `require-scope` | `false` | Require scope in every message |
| `ignore-commits` | — | Patterns to ignore (regex, newline-separated) |
| `validate-pr-title` | `false` | Also validate PR title |
| `pr-comment` | `none` | When to PR comment: none, error, success, both |

**Output:** `status` — `success` or `failure`

### Script Conventions

- Bash strict mode: `set -euo pipefail`
- Inputs via environment: `INPUT_BASE_SHA`, `INPUT_HEAD_SHA`, etc.
- Fallback logic: `GITHUB_BASE_REF` → `remotes/origin/$GITHUB_BASE_REF` → `main` → `master`
- Commits via `git rev-list`, each message validated individually
- Scope validation uses regex patterns

### Usage Example

```yaml
- name: Validate conventional commits
  uses: helpers4/action/conventional-commits@v1
  with:
    base-sha: ${{ github.event.pull_request.base.sha }}
    head-sha: ${{ github.event.pull_request.head.sha }}
    types: 'feat|fix|refactor'
    require-scope: true
```

### CI/CD Workflows

| Workflow | Trigger | Jobs |
|----------|---------|------|
| `pr-validation.yml` | Pull request → main | conventional-commits, shellcheck, test-action, pr-comment |

- **conventional-commits** — Validates PR commit messages against conventional commit format
- **shellcheck** — Lints `validate.sh` with ShellCheck
- **test-action** — Syntax check and basic validation of the action script
- **pr-comment** — Posts/updates a status summary comment on the PR

### Adding a New Action

1. Create `<action-name>/action.yml`
2. Create `<action-name>/scripts/` with implementation
3. Create `<action-name>/README.md`
4. Update root `README.md`
5. **Update `.github/workflows/pr-validation.yml`** — Add shellcheck/test jobs for the new action
6. Update this `AGENTS.md` (scopes + structure)

### License Header (required on all scripts)

```bash
# This file is part of helpers4.
# Copyright (C) 2025 baxyz
# SPDX-License-Identifier: LGPL-3.0-or-later
```
## Repository Links

- TypeScript: https://github.com/helpers4/typescript
- DevContainer: https://github.com/helpers4/devcontainer
- Actions: https://github.com/helpers4/action
- Website: https://github.com/helpers4/website
- Organization: https://github.com/helpers4

## Questions?

If you need clarification on any aspect, open an issue or comment on the PR. We're here to help!
