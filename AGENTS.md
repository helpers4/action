# AGENTS.md — action

→ [Org-wide rules](https://github.com/helpers4/.dev/blob/main/AGENTS.md): restrictions · commit format · license headers

## This Repository

**Purpose:** Reusable GitHub Actions published at `helpers4/action/<name>@v1`.

```text
action/
└── conventional-commits/
    ├── action.yml       # composite action — inputs, outputs
    ├── README.md
    └── scripts/
        └── validate.sh  # set -euo pipefail · inputs via INPUT_* env vars
```

**conventional-commits action — key inputs:**

| Input | Default | Notes |
| ----- | ------- | ----- |
| `base-sha` / `head-sha` | — | commit range to validate |
| `types` | `feat\|fix\|docs\|...` | pipe-separated regex |
| `scopes` | — | pipe-separated regex |
| `require-scope` | `false` | |
| `validate-pr-title` | `false` | |
| `pr-comment` | `none` | `none\|error\|success\|both` |

Output: `status` → `success` or `failure`.
SHA fallback chain: `GITHUB_BASE_REF` → `remotes/origin/$GITHUB_BASE_REF` → `main` → `master`.

**Adding a new action:** `<name>/action.yml` + `scripts/` + `README.md` + update root `README.md` + add shellcheck/test jobs to `pr-validation.yml` + add scope to `.vscode/settings.json`.

**License header (all scripts):**

```bash
# This file is part of helpers4.
# Copyright (C) 2025 baxyz
# SPDX-License-Identifier: LGPL-3.0-or-later
```
