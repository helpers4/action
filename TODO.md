# TODO — `helpers4/action`

> Last refresh: 2026-07-28 (updated same day: 3 candidates built and rolled out to all four
> consumer repos, see below).

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

## Roll out new actions to consumers — done

> `setup-pnpm`, `pr-status-comment`, and `trigger-website-update` were built and dogfooded in this
> repo itself (#12, #13), then rolled out to all four consumers below (2026-07-28). Kept here
> briefly rather than only in git history since two follow-ups fell out of the rollout that are
> still open — see the next section.

- [x] **`website`** ([PR #55](https://github.com/helpers4/website/pull/55), merged) — `build`/
  `lighthouse`/`typecheck` jobs → `setup-pnpm` (first real, non-smoke-test exercise of it),
  status-comment → `pr-status-comment`, 3 `on-*-release.yml` handlers → `setup-pnpm`. Pure
  extraction, CI green.
- [x] **`devcontainer`** ([PR #49](https://github.com/helpers4/devcontainer/pull/49)) —
  `shellcheck` job → `ludeeus/action-shellcheck` (scoped to preserve the exact previous
  install.sh-only coverage), status-comment → `pr-status-comment`. `release.yml`'s per-feature
  `gh api` dispatch loop → a dynamic matrix (`fromJson(needs.detect.outputs.changed)`) calling
  `trigger-website-update` once per changed feature — **could not be dry-run before merge** (no
  true no-op mode exists in this workflow, even `workflow_dispatch` + `force-all:false` still does
  a real publish); first real validation is the next actual feature version bump. CI green on
  everything that *could* run pre-merge.
- [x] **`typescript`** ([PR #123](https://github.com/helpers4/typescript/pull/123)) — all 7
  `job-*.yml` reusable workflows → `setup-pnpm`; status-comment → `pr-status-comment` with the
  coverage/mutation/runtime/bench sections preserved via `extra-markdown`; `release.yml`'s
  primary+Pushinator-fallback dispatch → one `trigger-website-update` call (fallback built in).
  `helpers4/action` refs pinned to a commit SHA here, not `@main` — matches this repo's existing
  SHA-pinning convention (the only repo that pins third-party actions this strictly).
- [x] **`.github`** ([PR #7](https://github.com/helpers4/.github/pull/7)) — all 3
  `manual-fallback-website-*.yml` → `trigger-website-update`. **Also found and fixed a real
  pre-existing bug while here**: these 3 files (+ their README runbook) lived at `workflows/*.yml`
  (repo-root), not `.github/workflows/` — GitHub never registered them as runnable workflows,
  confirmed via the Actions API (only `reusable-auto-assign.yml`/`reusable-proof-html.yml` showed
  up). Moved to the real path so the documented manual-fallback runbook actually works for the
  first time.

---

## Follow-ups found during rollout

- [ ] 🟡 `helpers4/.github` repo: `workflows/auto-assign.yml` has the **same misplacement bug** as
  the manual-fallback files above (repo-root `workflows/`, not `.github/workflows/`) — confirmed
  dead the same way. This repo's own issues/PRs have never been auto-assigned. Deliberately not
  fixed alongside PR #7 since enabling it is a real behavior change (unlike the user-triggered
  manual fallbacks), not a drive-by fix — needs its own decision on whether auto-assign should be
  active on `helpers4/.github` itself.
- [ ] 🟢 `typescript/.github/workflows/job-pr-comment.yml` is dead code — a standalone PR-comment
  reusable workflow (`workflow_call` with `pr-number`/`*-status`/coverage inputs) that nothing in
  the repo actually calls (`grep -rl job-pr-comment .github/workflows/` finds no references).
  Predates the `pr-status-comment` rollout and wasn't part of it — noted here since it was spotted
  in passing while editing `typescript`'s other workflow files. Either delete it or find out why it
  was orphaned.
