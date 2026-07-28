# PR Status Comment

Post or update a single sticky PR comment summarizing job statuses as a table — collapses the
~80-line `actions/github-script` block (build a table, find-or-create/update a bot comment)
duplicated across every helpers4 repo's `pr-validation.yml` into one step. Posting itself is
delegated to [`marocchino/sticky-pull-request-comment`](https://github.com/marocchino/sticky-pull-request-comment)
rather than reimplemented.

## Inputs

- **jobs** (required): JSON object mapping a display label to a status, e.g.
  `{"🧾 Conventional Commits": "success", "🏗️ Build": "failure"}`. Use
  `needs.<job>.result` for each entry — GitHub Actions exposes this natively, no custom
  `outputs.status` plumbing needed in the upstream jobs.
- **extra-markdown**: Additional Markdown appended after the status table (default: none). Use
  this for repo-specific sections (coverage, mutation testing, benchmarks, …) instead of
  reimplementing the table logic per repo.
- **comment-header**: Header used to identify the sticky comment to update (default:
  `PR Validation`). Only relevant if you post more than one sticky comment on the same PR.
- **github-token**: Token used to create/update the comment (default: `github.token`).

## Examples

### Basic usage

```yaml
pr-comment:
  runs-on: ubuntu-latest
  needs: [conventional-commits, build, test]
  if: always()
  steps:
    - uses: helpers4/action/pr-status-comment@v1
      with:
        jobs: |
          {
            "🧾 Conventional Commits": "${{ needs.conventional-commits.result }}",
            "🏗️ Build": "${{ needs.build.result }}",
            "🧪 Tests": "${{ needs.test.result }}"
          }
```

### With extra Markdown sections

```yaml
- uses: helpers4/action/pr-status-comment@v1
  with:
    jobs: |
      {
        "🏗️ Build": "${{ needs.build.result }}",
        "🧪 Tests": "${{ needs.test.result }}"
      }
    extra-markdown: |
      ### 📊 Code Coverage

      > 🎯 **Overall Coverage: ${{ needs.test.outputs.coverage }}%**
```
