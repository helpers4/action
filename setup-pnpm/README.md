# Setup pnpm

Set up Node.js and pnpm in one step, optionally installing dependencies. Wraps the official
[`pnpm/action-setup`](https://github.com/pnpm/action-setup) (actively maintained by the pnpm org)
rather than `corepack enable` — Node.js is removing Corepack from its default distribution
starting with Node.js 26, so relying on it to install pnpm is no longer safe.

## Requirements

- Checkout the repository yourself before this action (with the `fetch-depth` your job needs) —
  this action does not run `actions/checkout`, since callers differ on depth.
- The repo's `packageManager` field in `package.json` selects the pnpm version by default; pass
  the **version** input explicitly for repos without one.

## Inputs

- **node-version** (required): Node.js version to install, passed straight to
  `actions/setup-node`.
- **version**: pnpm version to install (default: empty — auto-detected from the
  `packageManager` field in `package.json`). Required if the repo has no `package.json` or no
  `packageManager` field.
- **install**: Run `pnpm install` after setup (default: `true`). Set to `false` if you only need
  Node + pnpm on `PATH` without installing dependencies.
- **frozen-lockfile**: Pass `--frozen-lockfile` to `pnpm install` (default: `true`). Set to
  `false` for workflows that intentionally update the lockfile.
- **working-directory**: Directory containing `package.json`/`pnpm-lock.yaml`, and where
  `pnpm install` runs (default: `.`).
- **cache**: Cache the pnpm store directory, passed straight to `pnpm/action-setup`'s own `cache`
  input (default: `true`).

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

### Repo without a package.json (explicit version)

```yaml
- uses: actions/checkout@v7
- uses: helpers4/action/setup-pnpm@v1
  with:
    node-version: "24"
    version: "10"
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
