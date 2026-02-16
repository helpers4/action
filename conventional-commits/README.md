# Conventional Commits Check

Validate commit messages against the Conventional Commits specification.

## Requirements

- By default, this action runs actions/checkout with fetch-depth: 0 so the commit history is available.
- Set checkout: false if you already checked out the repository with the correct history depth.

## Inputs

### Basic Configuration

- **checkout**: Whether to run actions/checkout before validation (default: `true`).
- **base-sha**: Base commit SHA to compare against (optional; defaults to merge-base with origin/$GITHUB_BASE_REF, origin/main, or origin/master).
- **head-sha**: Head commit SHA to validate (optional; defaults to HEAD).
- **pr-comment**: Comment on PR with validation results - `none`, `error`, `success`, or `both` (default: `error`).

### Advanced Configuration

- **types**: Allowed types (pipe-separated, default: `feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert`).
  - Example: `feat|fix|hotfix` to only allow these types
  - Supports regex patterns: `feat|fix|JIRA-\d+`

- **scopes**: Allowed scopes (regex patterns, pipe-separated, default: empty = all allowed).
  - Example: `api|ui|core` to restrict to these scopes
  - Example: `[a-z]+` to only allow lowercase scopes
  - Example: `JIRA-\d+|PROJ-\d+` to require ticket numbers

- **require-scope**: Require a scope in each commit message (default: `false`).

- **ignore-commits**: Patterns to ignore (regex, newline-separated).
  - Example: `^Merge branch|^Revert` to skip merge commits
  - Useful for automated commits

- **validate-pr-title**: Also validate the PR title against conventional commits format (default: `false`).

## Outputs

- **status**: Validation status - `success` or `failure`
- **invalid-count**: Number of invalid commits
- **valid-count**: Number of valid commits  
- **error-message**: Detailed error message if validation failed

## Examples

### Basic Usage (pull_request)

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

### With Custom Types

```yaml
- name: Validate commits
  uses: helpers4/action/conventional-commits@v1
  with:
    types: 'feat|fix|hotfix|chore'
```

### With Scope Validation

```yaml
- name: Validate commits  
  uses: helpers4/action/conventional-commits@v1
  with:
    scopes: 'api|ui|core|docs'
    require-scope: 'true'
```

### With Ticket Numbers in Scopes

```yaml
- name: Validate commits
  uses: helpers4/action/conventional-commits@v1
  with:
    scopes: 'JIRA-\d+|PROJ-\d+'
    require-scope: 'true'
    # Valid: feat(JIRA-123): add feature
    # Invalid: feat: add feature (no scope)
```

### Ignore Automated Commits

```yaml
- name: Validate commits
  uses: helpers4/action/conventional-commits@v1
  with:
    ignore-commits: |
      ^Merge branch
      ^Revert
      ^chore\(deps\):
```

### Validate PR Title + Commits

```yaml
- name: Validate commits and PR title
  uses: helpers4/action/conventional-commits@v1
  with:
    validate-pr-title: 'true'
    pr-comment: 'both'
```

### Using Outputs

```yaml
- name: Validate commits
  id: validate
  uses: helpers4/action/conventional-commits@v1
  
- name: Post custom comment
  if: steps.validate.outputs.status == 'failure'
  run: |
    echo "Found ${{ steps.validate.outputs.invalid-count }} invalid commits"
    echo "Error: ${{ steps.validate.outputs.error-message }}"
```

### Advanced Example with All Options

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

## Configuration Details

### Types

The default types follow the [Conventional Commits specification](https://www.conventionalcommits.org/):
- `feat`: A new feature
- `fix`: A bug fix
- `docs`: Documentation only changes
- `style`: Changes that don't affect code meaning (formatting, etc.)
- `refactor`: Code change that neither fixes a bug nor adds a feature
- `perf`: Code change that improves performance
- `test`: Adding or correcting tests
- `build`: Changes to build system or dependencies
- `ci`: Changes to CI configuration
- `chore`: Other changes that don't modify src or test files
- `revert`: Reverts a previous commit

You can customize this list to match your workflow.

### Scopes

Scopes are optional identifiers that provide additional context. Common patterns:
- Component names: `(api)`, `(ui)`, `(auth)`
- Ticket numbers: `(JIRA-123)`, `(GH-456)`
- Feature areas: `(dashboard)`, `(settings)`

Use the `scopes` input to restrict which scopes are allowed (regex patterns).
Use `require-scope: true` to make scopes mandatory.

### PR Comments

The action can automatically comment on PRs with validation results:
- `none` or `false`: No comments
- `error`: Comment only on failures (default)
- `success`: Comment only on success
- `both` or `true`: Always comment
