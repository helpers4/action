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
>
> **Checked the GitHub Marketplace before adding any of these** (2026-07-28) — two items below
> changed as a result; don't re-litigate without new evidence:
>
> - **ShellCheck runner dropped entirely** — [`ludeeus/action-shellcheck`](https://github.com/ludeeus/action-shellcheck)
>   (350★, active) already does exactly this (recursive scan, configurable options/paths). No
>   reason to build and maintain our own; adopt it directly in `action` and `devcontainer` instead.
> - **"Set job status output" isn't an extraction candidate at all** — GitHub Actions natively
>   exposes `needs.<job_id>.result` (`success`/`failure`/`skipped`/`cancelled`) for any job listed
>   as a direct dependency, no explicit output plumbing required. The `if [ "${{ job.status }}"...
>   ] echo "status=..." >> $GITHUB_OUTPUT` step in every job is dead weight that can just be
>   deleted, with downstream jobs reading `needs.<job>.result` instead of
>   `needs.<job>.outputs.status`. Not a new-action item — a cleanup item, moved out of this list
>   (see `typescript`/`website`/`devcontainer` TODOs or handle inline next time one of these
>   `pr-validation.yml` files is touched).

- [ ] 🔴 **PR-validation status-comment table** — the ~80-line `actions/github-script` block that
  builds a `| icon | job | passing/failing |` table and creates-or-updates a single bot comment on
  the PR is duplicated near-verbatim in `action/pr-validation.yml`, `typescript/pr-validation.yml`,
  `website/pr-validation.yml`, and `devcontainer/pr-validation.yml` — 4 copies, only the job-name
  list differs (`typescript`'s also bolts on coverage/mutation/runtime/bench sections, but the
  core table-building + find-or-create-comment logic is identical). **Marketplace check**:
  [`marocchino/sticky-pull-request-comment`](https://github.com/marocchino/sticky-pull-request-comment)
  (642★, active) already solves the fiddly half of this — find-or-create/update a single bot
  comment — but no generic action renders our specific formatted table (icons, coverage bars,
  mutation/bench sections). Build this as a thin composite action that assembles the Markdown
  from a JSON `{ "label": "status" }` input and delegates the actual posting to
  `sticky-pull-request-comment`, rather than reimplementing comment CRUD ourselves.
- [ ] 🔴 **Node + pnpm setup boilerplate** — `actions/checkout` → `actions/setup-node` →
  `corepack enable` (or `pnpm/action-setup`) → `pnpm install --frozen-lockfile` repeats **15+
  times**: all 7 of `typescript`'s `job-*.yml` reusable workflows, 3 jobs inside
  `website/pr-validation.yml` (build/lighthouse/typecheck), `website`'s 3 `on-*-release.yml`
  handlers, and `action/pr-validation.yml`'s `test-action`/`build` jobs. `typescript` already
  half-solved this for itself via its own reusable `job-*.yml` files, but `website` and `action`
  still repeat the raw 4-step sequence inline. **Marketplace check**:
  [`dafnik/setup-node-pnpm`](https://github.com/dafnik/setup-node-pnpm) exists but is only 3★ and
  young, and doesn't explicitly expose `corepack enable`/`--frozen-lockfile` the way our jobs need
  — too immature to add as a supply-chain dependency given this org's pinned-SHA/Scorecard
  posture. Still the highest-value extraction by copy count; build our own.
- [ ] 🟡 **`trigger-website-update` (Trigganator dispatch)** — "get a GitHub App token scoped to
  `helpers4/website` → `peter-evans/repository-dispatch` with an `event-type`/`client-payload`"
  repeats **7 times**: `action/release.yml`, `devcontainer/release.yml`, `typescript/release.yml`
  (twice — primary + Pushinator fallback), and all three `.github/workflows/manual-fallback-
  website-*.yml` files (verified byte-for-byte identical apart from repo name/event-type/payload).
  **Marketplace check**: the two underlying primitives we already use —
  [`actions/create-github-app-token`](https://github.com/actions/create-github-app-token) (865★,
  official) and [`peter-evans/repository-dispatch`](https://github.com/peter-evans/repository-dispatch)
  (1203★) — are both solid; no third-party action packages "token + dispatch + fallback retry" as
  one step for our specific case, so there's nothing to adopt instead. The duplication is in our
  own assembly, not the primitives. A composite action taking `event-type` + `payload` (+ optional
  fallback app-id/key) inputs would let every caller drop to ~5 lines and fix the retry/fallback
  logic in one place instead of only `typescript` having it.
