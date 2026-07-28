# TODO — `helpers4/action`

> Last refresh: 2026-07-28 (updated same day: 3 candidates built, see "Roll out new actions to
> consumers" below).

Legend: 🔴 High priority · 🟡 Medium · 🟢 Low

Only open items live here. Anything finished is in git history, not duplicated in this file.

---

## OpenSSF Scorecard

> Already set up on `typescript` (`.github/workflows/scorecard.yml`, weekly cron +
> `workflow_dispatch`, uploads SARIF to code scanning via `ossf/scorecard-action`). Confirmed via
> `website/TODO.md` §7 that this repo currently returns a real `404` from
> `api.securityscorecards.dev` — OpenSSF has never scanned it because the workflow doesn't exist
> here yet. Once it does, the website's `ProjectCard` component will start showing a score for
> `action` automatically (fetch already runs for all three `PROJECTS` entries, no website change
> needed).

- [ ] 🟡 Add `.github/workflows/scorecard.yml`, mirroring `typescript`'s — same triggers
  (`schedule: "30 1 * * 1"` + `workflow_dispatch`), same `permissions: read-all` at workflow level
  with the job-level `security-events: write` / `id-token: write` / `contents: read` /
  `actions: read` set, same `ossf/scorecard-action` + SARIF upload steps. Needs a
  `SCORECARD_TOKEN` repo secret (PAT with `security_events` write) before the token line will
  actually publish results — check whether `typescript`'s can be reused org-wide or a new one is
  needed for this repo.
- [ ] 🟢 Add the shields.io Scorecard badge to this repo's `README.md` once the workflow has run at
  least once (same pattern as `typescript`'s README).

---

## GitHub Marketplace

- [ ] 🟡 **Root-level blocker**: GitHub only shows the "Publish this Action to the GitHub
  Marketplace" checkbox on a release when it detects `action.yml`/`action.yaml` at the
  **repository root** — `conventional-commits/action.yml` (checked 2026-07-28) is one level down.
  Needs a decision before this can ship:
  - (a) Move `conventional-commits`'s contents up to repo root (only works while this repo hosts a
    single action — blocks adding a second action later without a restructure), or
  - (b) Split each action into its own repo (`helpers4/action-conventional-commits`, …) so each
    can be tagged/published independently — more repos to maintain, but matches how most
    multi-action GitHub orgs actually do it.
- [ ] 🟢 Once the layout is settled: cut a semver-tagged release (`v1`, `v1.0.0`), fill in the
  release-creation "Publish to Marketplace" flow (primary/secondary category — likely
  "Continuous Integration" — plus the existing `branding` icon/color from `action.yml` feeds the
  listing card automatically), and confirm the listing renders correctly.

---

## Roll out new actions to consumers

> `setup-pnpm`, `pr-status-comment`, and `trigger-website-update` were built and dogfooded in this
> repo itself (#12, #13) — see git history, not duplicated here. `action`'s own CI has no
> Node/pnpm build step, so `setup-pnpm` hasn't had a real exercise yet (only a smoke test);
> `pr-status-comment` and `trigger-website-update` are live in this repo's `pr-validation.yml` /
> `release.yml`. **Gate**: don't start any item below until #12/#13 are merged and this repo's own
> CI has run green on `main` at least once with them — that's the first real validation these
> actions get before spreading them to other repos' release pipelines.

- [ ] 🟡 **`website`**: swap the `build`/`lighthouse`/`typecheck` jobs' setup sequence in
  `pr-validation.yml` for `setup-pnpm` (first real, non-smoke-test exercise of it), the
  status-comment block for `pr-status-comment`, and the 3 `on-*-release.yml` handlers' Node/pnpm
  setup for `setup-pnpm` too. Lowest-risk consumer repo to go first — no release-automation
  behavior change involved, pure extraction.
- [ ] 🟡 **`devcontainer`**: `pr-validation.yml`'s `shellcheck` job → `ludeeus/action-shellcheck`
  (keep the separate "bootstrap copies match canonical" check as its own step), status-comment
  block → `pr-status-comment`. **`release.yml` needs more care, not a blind swap**: it dispatches
  once *per changed feature* via a bash loop calling `gh api` directly, not a single
  `peter-evans/repository-dispatch` call like the others — using `trigger-website-update` means
  turning that loop into a dynamic matrix (`fromJson(needs.detect.outputs.changed)`), a real
  behavior change to GHCR publish automation the whole org depends on. Dry-run via
  `workflow_dispatch` + `force-all: false` before merging.
- [ ] 🟡 **`typescript`** (largest single diff): all 7 `job-*.yml` reusable workflows swap their
  `checkout → setup-node → corepack → pnpm install` sequence for `setup-pnpm`; `pr-validation.yml`
  status-comment block → `pr-status-comment` with the existing coverage/mutation/runtime/bench
  sections passed via `extra-markdown` so none of that formatting is lost; `release.yml`'s
  primary-plus-Pushinator-fallback dispatch in `trigger-website-docs` collapses into one
  `trigger-website-update` call (fallback built in).
- [ ] 🟢 **`.github`**: all 3 `manual-fallback-website-*.yml` files → `trigger-website-update`,
  each dropping from ~37-42 lines to roughly 10.
