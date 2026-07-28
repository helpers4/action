# Setup pnpm

Setup Node.js + pnpm via corepack, optionally installing dependencies — collapses the
`actions/setup-node` → `corepack enable` → `pnpm install` sequence duplicated across every
helpers4 repo's CI into one step.

## Requirements

- Checkout the repository yourself before this action (with the `fetch-depth` your job needs) —
  this action does not run `actions/checkout`, since callers differ on depth.
- The repo's `packageManager` field in `package.json` selects the pnpm version; corepack reads it
  automatically after `corepack enable`.

## Inputs

- **node-version** (required): Node.js version to install, passed straight to
  `actions/setup-node`.
- **install**: Run `pnpm install` after setup (default: `true`). Set to `false` if you only need
  Node + pnpm on `PATH` without installing dependencies.
- **frozen-lockfile**: Pass `--frozen-lockfile` to `pnpm install` (default: `true`). Set to
  `false` for workflows that intentionally update the lockfile.
- **working-directory**: Directory to run `pnpm install` in (default: `.`).

## Outputs

None — Node.js and pnpm are left configured on `PATH` for subsequent steps.

## Examples

### Basic usage

```yaml
- uses: actions/checkout@v7
- uses: helpers4/action/setup-pnpm@v1
  with:
    node-version: "26"
- run: pnpm build
```

### Setup only, no install

```yaml
- uses: actions/checkout@v7
- uses: helpers4/action/setup-pnpm@v1
  with:
    node-version: "26"
    install: "false"
- run: pnpm --version
```

### Non-frozen lockfile (e.g. a release job that bumps versions)

```yaml
- uses: helpers4/action/setup-pnpm@v1
  with:
    node-version: "26"
    frozen-lockfile: "false"
```
