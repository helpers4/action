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
