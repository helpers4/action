# Dispatch with Fallback

Dispatch a `repository_dispatch` event to a repository via a GitHub App token, with an optional
fallback identity retried automatically on failure — collapses the "get a GitHub App token →
`peter-evans/repository-dispatch`" sequence duplicated across every helpers4 release workflow
(and the `.github` manual-fallback workflows) into one step, with retry-on-failure built in for
every caller instead of only `typescript` having it.

Fully generic — nothing in this action assumes a particular org or target repository; every
caller in the helpers4 org happens to point it at `helpers4/website` today, but that's just how
it's used here, not something baked into the action.

## Inputs

- **target-owner** (required): Owner of the target repository.
- **target-repo** (required): Name of the target repository, without owner.
- **event-type** (required): `repository_dispatch` event type, e.g. `action-release`.
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
- name: Trigger website update
  continue-on-error: true
  uses: helpers4/action/dispatch-with-fallback@v1
  with:
    target-owner: helpers4
    target-repo: website
    event-type: action-release
    payload: '{"version": "${{ github.ref_name }}"}'
    app-id: ${{ vars.TRIGGANATOR_ID }}
    app-private-key: ${{ secrets.TRIGGANATOR_KEY }}
```

### With fallback identity (matches `typescript`'s Trigganator → Pushinator retry)

```yaml
- name: Trigger website docs update
  uses: helpers4/action/dispatch-with-fallback@v1
  with:
    target-owner: helpers4
    target-repo: website
    event-type: typescript-release
    payload: '{"version": "${{ needs.publish.outputs.new-version }}"}'
    app-id: ${{ vars.TRIGGANATOR_ID }}
    app-private-key: ${{ secrets.TRIGGANATOR_KEY }}
    fallback-app-id: ${{ vars.PUSHINATOR_ID }}
    fallback-app-private-key: ${{ secrets.PUSHINATOR_KEY }}
```
