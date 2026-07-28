# Trigger Website Update

Dispatch a `repository_dispatch` event to `helpers4/website` via a GitHub App token, with an
optional fallback identity — collapses the "get a GitHub App token → `peter-evans/repository-
dispatch`" sequence duplicated across every release workflow (and the `.github` manual-fallback
workflows) into one step, with retry-on-failure built in for every caller instead of only
`typescript` having it.

## Inputs

- **event-type** (required): `repository_dispatch` event type, e.g. `action-release`,
  `devcontainer-release`, `typescript-release`.
- **payload** (required): JSON string sent as `client_payload`, e.g.
  `{"version": "${{ github.ref_name }}"}`.
- **app-id** / **app-private-key** (required): GitHub App credentials for the primary token.
- **fallback-app-id** / **fallback-app-private-key**: GitHub App credentials retried if the
  primary dispatch fails (optional — omit to skip the fallback entirely).
- **target-owner**: Owner of the target repository (default: `helpers4`).
- **target-repo**: Name of the target repository, without owner (default: `website`).

## Behavior

If the primary dispatch fails and no fallback credentials are given, this action fails (unless
the caller sets `continue-on-error: true` on its own step, matching each repo's existing
non-blocking convention for this trigger). If fallback credentials are given, it retries once
with the fallback identity before failing.

## Examples

### Basic usage (no fallback, non-blocking — matches `action`/`devcontainer` release.yml today)

```yaml
- name: Trigger website update
  continue-on-error: true
  uses: helpers4/action/trigger-website-update@v1
  with:
    event-type: action-release
    payload: '{"version": "${{ github.ref_name }}"}'
    app-id: ${{ vars.TRIGGANATOR_ID }}
    app-private-key: ${{ secrets.TRIGGANATOR_KEY }}
```

### With fallback identity (matches `typescript`'s Trigganator → Pushinator retry)

```yaml
- name: Trigger website docs update
  uses: helpers4/action/trigger-website-update@v1
  with:
    event-type: typescript-release
    payload: '{"version": "${{ needs.publish.outputs.new-version }}"}'
    app-id: ${{ vars.TRIGGANATOR_ID }}
    app-private-key: ${{ secrets.TRIGGANATOR_KEY }}
    fallback-app-id: ${{ vars.PUSHINATOR_ID }}
    fallback-app-private-key: ${{ secrets.PUSHINATOR_KEY }}
```
