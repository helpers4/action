# TODO — `helpers4/action`

> Last refresh: 2026-07-28.

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

## New reusable action candidates

> Surveyed every workflow file in all six repos (`.dev`, `.github`, `action`, `typescript`,
> `website`, `devcontainer`) on 2026-07-28, looking for CI logic copy-pasted across repos that
> could become a new composite action here (alongside `conventional-commits`) instead of staying
> duplicated. Ranked by how many times the exact pattern is repeated today.

- [ ] 🔴 **PR-validation status-comment table** — the ~80-line `actions/github-script` block that
  builds a `| icon | job | passing/failing |` table and creates-or-updates a single bot comment on
  the PR is duplicated near-verbatim in `action/pr-validation.yml`, `typescript/pr-validation.yml`,
  `website/pr-validation.yml`, and `devcontainer/pr-validation.yml` — 4 copies, only the job-name
  list differs (`typescript`'s also bolts on coverage/mutation/runtime/bench sections, but the
  core table-building + find-or-create-comment logic is identical). A composite action taking a
  JSON `{ "label": "status" }` map as input (plus optional extra Markdown sections) would collapse
  all four to a few lines each.
- [ ] 🔴 **Node + pnpm setup boilerplate** — `actions/checkout` → `actions/setup-node` →
  `corepack enable` (or `pnpm/action-setup`) → `pnpm install --frozen-lockfile` repeats **15+
  times**: all 7 of `typescript`'s `job-*.yml` reusable workflows, 3 jobs inside
  `website/pr-validation.yml` (build/lighthouse/typecheck), `website`'s 3 `on-*-release.yml`
  handlers, and `action/pr-validation.yml`'s `test-action`/`build` jobs. `typescript` already
  half-solved this for itself via its own reusable `job-*.yml` files, but `website` and `action`
  still repeat the raw 4-step sequence inline. Highest-value single extraction by copy count.
- [ ] 🟡 **`trigger-website-update` (Trigganator dispatch)** — "get a GitHub App token scoped to
  `helpers4/website` → `peter-evans/repository-dispatch` with an `event-type`/`client-payload`"
  repeats **7 times**: `action/release.yml`, `devcontainer/release.yml`, `typescript/release.yml`
  (twice — primary + Pushinator fallback), and all three `.github/workflows/manual-fallback-
  website-*.yml` files (verified byte-for-byte identical apart from repo name/event-type/payload).
  A composite action taking `event-type` + `payload` (+ optional fallback app-id/key) inputs would
  let every caller drop to ~5 lines and fix the retry/fallback logic in one place instead of only
  `typescript` having it.
- [ ] 🟡 **"Set job status output" step** — the 6-line `if [ "${{ job.status }}" == "success" ]
  ... echo "status=..." >> $GITHUB_OUTPUT` boilerplate repeats in nearly every job of every
  `pr-validation.yml` across `action`, `typescript`, `website`, and `devcontainer` (15+ occurrences
  counted). Smallest win per-copy but the most-repeated single snippet in the whole survey — worth
  it mainly because it'd also normalize the `job.status` vs `$JOB_STATUS` env-var inconsistency
  already visible between repos (some interpolate `${{ job.status }}` directly in `run:`, others
  pass it through `env:` first).
- [ ] 🟢 **ShellCheck runner** — checkout → `apt-get install shellcheck` → `shellcheck -S warning
  <path>` repeats in `action/pr-validation.yml` (`shellcheck` job) and
  `devcontainer/pr-validation.yml` (`shellcheck` job, which also does an extra bootstrap-diff
  check inline). Only 2 copies today, smaller payoff, but trivial to extract — a `path`/`glob`
  input composite action.
