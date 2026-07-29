# Dispatch with Fallback

Send a `repository_dispatch` event to a repository using a GitHub App token, with an optional
second identity retried automatically if the first attempt fails. Useful for cross-repo
automation — e.g. a release in one repo triggering a docs rebuild in another — where you want a
backup identity to retry with if the primary one hits a transient failure, rate limit, or
permission issue.

## Inputs

- **target-owner** (required): Owner of the target repository.
- **target-repo** (required): Name of the target repository, without owner.
- **event-type** (required): `repository_dispatch` event type.
- **payload** (required): JSON string sent as `client_payload`, e.g.
  `{"version": "${{ github.ref_name }}"}`.
- **app-id** / **app-private-key** (required): GitHub App credentials for the primary token.
- **fallback-app-id** / **fallback-app-private-key**: GitHub App credentials retried if the
  primary dispatch fails (optional — omit to skip the fallback entirely).

## Behavior

If the primary dispatch fails and no fallback credentials are given, this action fails (unless
the caller sets `continue-on-error: true` on its own step). If fallback credentials are given, it
retries once with the fallback identity before failing.

## Examples

### Basic usage (no fallback, non-blocking)

```yaml
- name: Notify docs repo
  continue-on-error: true
  uses: helpers4/action/dispatch-with-fallback@v1
  with:
    target-owner: my-org
    target-repo: docs-site
    event-type: upstream-release
    payload: '{"version": "${{ github.ref_name }}"}'
    app-id: ${{ vars.RELEASE_APP_ID }}
    app-private-key: ${{ secrets.RELEASE_APP_KEY }}
```

### With a fallback identity

```yaml
- name: Notify docs repo
  uses: helpers4/action/dispatch-with-fallback@v1
  with:
    target-owner: my-org
    target-repo: docs-site
    event-type: upstream-release
    payload: '{"version": "${{ needs.publish.outputs.new-version }}"}'
    app-id: ${{ vars.RELEASE_APP_ID }}
    app-private-key: ${{ secrets.RELEASE_APP_KEY }}
    fallback-app-id: ${{ vars.BACKUP_APP_ID }}
    fallback-app-private-key: ${{ secrets.BACKUP_APP_KEY }}
```
