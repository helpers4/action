# Conventional Commits Check

Validate commit messages against the Conventional Commits specification.

## Requirements

- By default, this action runs actions/checkout with fetch-depth: 0 so the commit history is available.
- Set checkout: false if you already checked out the repository with the correct history depth.

## Inputs

- checkout: Whether to run actions/checkout before validation (default: true).
- base-sha: Base commit SHA to compare against (optional; defaults to merge-base with origin/$GITHUB_BASE_REF, origin/main, or origin/master).
- head-sha: Head commit SHA to validate (optional; defaults to HEAD).

## Example (pull_request)

```yaml
name: Conventional Commits

on:
  pull_request:

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - name: Validate commits
        uses: helpers4/action/conventional-commits@v1
        with:
          base-sha: ${{ github.event.pull_request.base.sha }}
          head-sha: ${{ github.event.pull_request.head.sha }}
```

## Example (push)

```yaml
name: Conventional Commits

on:
  push:

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - name: Validate commits
        uses: helpers4/action/conventional-commits@v1
        with:
          base-sha: ${{ github.event.before }}
          head-sha: ${{ github.sha }}
```
