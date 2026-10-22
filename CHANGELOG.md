## Unreleased — 2026-10-21 — OSS publication: governance, security and bilingual README

Preparation to publish the template as open source. No schema or example-content
changes: the workspace still validates against `@profile-as-code/cli@0.3.0`
(`validate` 0 findings, `check` 0 findings, 2026-10-21).

- **Missing governance**
  - `SECURITY.md` — private channel (GitHub advisory), scope (workflows, docs,
    bootstrap, example data), out of scope (engine, forks, platform), expected
    latency (ack ≤3 business days, triage ≤7, disclosure 90 days) and the
    hardening baseline. Forks are explicitly out: the maintainer has no access
    to them.
  - `CODE_OF_CONDUCT.md` — a real enforcement channel (private advisory with a
    `conduct:` prefix), confidentiality, a 5-day SLA and the consequence ladder.
    It used to say "report to the leaders" without saying how.
  - `.github/ISSUE_TEMPLATE/` (bug, feature, config) and
    `PULL_REQUEST_TEMPLATE.md` — with the privacy rule up front: never real
    data, private media or tokens in a public thread.
  - `CONTRIBUTING.md` — a "Before you open anything" section (routing by report
    type), a 7-day triage expectation, README EN/ES parity and the SHA-pin rule
    for actions.
- **CI security**
  - **All actions pinned by commit SHA** (`checks.yml` and `workflow-lint.yml`
    used `@v4`; `build.yml` already did). A re-pointed tag is arbitrary code
    holding the job token.
  - **`dependabot.yml`** — updates the GitHub Actions pins weekly.
  - **`secrets` job** — gitleaks OSS (MIT) with a pinned version and SHA-256
    over the full history. The CLI was chosen over `gitleaks-action` because
    this template is forked: a commercial EULA is not pushed onto every fork.
  - **`example-data` job** — `.github/scripts/check-example-data.sh` fails if
    `content/identity.yaml` stops declaring the fictional persona, if an email
    leaves `example.*`, if an absolute home path or a non-http(s) scheme shows
    up in `content/`, if `media/` ships a binary, or if `.pasco/`/`.env*` gets
    tracked. **It runs only in the template repo** (a fork carries a real
    identity: the job skips there and the script does not apply).
  - **`.gitignore`** — `.pasco/` (the `local.toml` can hold an absolute evidence
    root, and the docs already said it was ignored), `node_modules/`, `*.log`.
- **Docs for an outside visitor**
  - `README.md` rewritten in English (primary OSS language, D8) with badges, a
    "this is the template / this is the engine" table, status, a private-first
    quickstart, repo map, CI, security, troubleshooting and roadmap.
    `README.es.md` is the maintained translation.
  - Pointers to `schema/profile.schema.json`, `docs/SPEC.md` and
    `docs/research/01-prior-art.md` are now absolute URLs to the engine repo:
    they used to be relative paths that do not exist here (a 404 for an outsider).
  - `pasco check`/`pasco refine` described according to the real 0.3.0 CLI
    (`check` executes registry and media rules; `refine` is PARTIAL), not as stubs.
  - `media/README.md` — the git-lfs brace pattern (`*.{mp4,zip,psd}`) does not
    expand: replaced with one pattern per extension, and it is now explicit that
    this template ships `media/` empty.
  - `CHECKLIST.md` — workspace privacy section before deploying.
  - `docs/STANDARDS.md` and `AGENTS.md` — security rules, private disclosure,
    README parity, SHA pinning and the ban on flipping visibility/merging from an
    agent session.
- **Documentation language (D8)**
  - `CHECKLIST.md`, `CHANGELOG.md`, `profiles/README.md` and the `content/*.yaml`
    comments are in English now. `CHECKLIST.es.md` is a hand-maintained Spanish
    translation; the engine only regenerates `CHECKLIST.md` (in English), so the
    Spanish file must be re-synced by hand after `--write-checklist`. One data
    value was normalized: the example venue `Physical Review C (ficticio)` →
    `(fictional)`.
- **Local verification (2026-10-21):** `check-links.sh` OK ·
  `check-example-data.sh` OK · `pasco validate` 0 findings · `pasco check`
  0 findings · workflows and `dependabot.yml` parse · history with no credential
  pattern matches.

## v0.3.0 — 2026-10-12 — first scaffold release: complete CONTRIBUTING + release (issue #12, ROADMAP item 7)
- What changed:
  - **First scaffold tag: `v0.3.0`** — from here the template is versioned by
    mirroring the engine pin: `MAJOR.MINOR` = `@profile-as-code/cli`, `PATCH` = the
    scaffold's own revision. Cutting the tag and re-syncing a fork:
    `CONTRIBUTING.md` § Releases. Entries before this one carry no tag (pre-release
    history); the tag is created on `main` at the merge commit.
  - **`.pascorc` → `diff.tagPattern: "v*"`** — it shipped the `release-*` default,
    which does not match the release tag. Reproduced against engine 0.3.0 in a test
    repo (tag `v0.3.0` mid-history): with `v*` → `tag: v0.3.0`, base = the release
    commit, 1 commit since the tag; with `release-*` → `tag: null`, base = first
    commit, 2 commits (the release itself included). The default would have made
    `pasco diff` never see the release.
  - **Complete `CONTRIBUTING.md`** — local setup with the **pinned** engine
    (`npm i -g @profile-as-code/cli@0.3.0`, bin `pasco`), the "never hand-edit
    `profiles/`" rule (`pasco build` + commit), a **CI** section (the two workflows,
    the bot exception and why its push does not trigger `checks.yml`) and a
    **Releases** section (version scheme + cutting the tag + re-syncing a fork). It
    no longer tells you to clone the engine or run
    `scripts/schema-check/check.py`: that is not the published interface.
  - **`docs/STANDARDS.md`** — the "Never push to `main`" rule now declares the
    exception `build.yml` executes (the bot commits `profiles/` in the user's
    workspace, never in the template: fail-closed guard), and the CI line names both
    workflows instead of only `checks.yml`.
  - **Deferred items from the two review comments on #12 (all 8):**
    - `content/bios.yaml` — `pac refine` → `pasco refine` (drift from rename #38).
    - `AGENTS.md` — `.pascorc` names its real keys (`workspace`, `defaults`,
      `diff`), a map row for `.github/scripts/`, and `pasco check` in the commands.
    - **A gate that parses the workflows** (job `yaml` in `checks.yml`):
      `checks.yml` itself documents the `startup_failure` caused by an incidental
      YAML alias and `build.yml` had no coverage; now both are parsed on every
      push/PR.
    - **The generated commit goes through a link check**: the bot's push uses
      `GITHUB_TOKEN` and GitHub runs no workflows for its own events ⇒ `checks.yml`
      never saw the generated `profiles/`. The link check runs **inside**
      `build.yml` before the commit, with the shared script
      `.github/scripts/check-links.sh` (one copy, two callers — the logic used to
      live inline in `checks.yml`).
    - **`build.yml`** — expression hoisted into `env:` (it interpolated before the
      shell saw the script); `is_template` guard **fail-closed** (field missing from
      the payload ⇒ error, not a blind push); actions of the job holding
      `contents: write` **pinned by SHA**, taken from the API: `actions/checkout`
      `11d5960a…` (= `v4`, tip 2026-07-16) and `actions/setup-node` `49933ea5…`
      (= `v4.4.0`).
- **Review rounds (same branch):** every fix reproduced before fixing:
  - **False claim "the engine is read-only except two exceptions that write only to
    `content/`"** — there are **four** writers and **two stay outside** `content/`:
    `pasco build` → `profiles/`, `pasco status --write-checklist` → `CHECKLIST.md`
    (verified in the engine: `status.ts` writes `join(workspace, "CHECKLIST.md")`;
    `refine.ts` → `content/active.yaml`). The same false sentence was in `README.md`
    → fixed in both.
  - **The workflow gate could not cover `checks.yml`**: a YAML error there is a
    `startup_failure`, so a job inside never runs to report it — the incident class
    the file itself documents. Moved to
    **`.github/workflows/workflow-lint.yml`**, which does not depend on the file it
    validates. Declared residual: an error in the lint itself is still a
    `startup_failure` (nothing validates itself).
  - **The link gate could pass silently**: if `git ls-files` fails, the list comes
    back empty and it reported success after checking 0 files → now exit 1
    (pre-existing in the inline version this PR extracted).
  - **False positives in the link regex** (`[x](f.md "title")`, `[x](<a b.md>)`) and
    the `|| true` comment, which claimed something false (a child shell does not
    inherit `-e`): regex hardened and comment rewritten.
  - The pin-surface list in § Releases omitted **this very file**, and the re-sync
    snippet did not work for a `--template` copy (no local tag) → both fixed.
  - New **link-gate self-test** in `checks.yml` (broken fixture ⇒ exit 1, in
    argument mode): no job exercised its failure path, because `build.yml` does not
    run that branch in this repo (`is_template: true`).
  - **Reconciliation of the published premerge verdict** (`PASS-CON-RIESGOS`, run
    against head `27e4560`, two commits back): its two MAJORs —F1 (gate green after
    checking 0 files) and F2 (the pin-surface list)— were already fixed in `d5a3d82`,
    and F3 in `bff8155`; F1 was reproduced on the current head and exits 1. The two
    NITs still alive are fixed here: rule 3 in `AGENTS.md` did not ask for
    `pasco check` (which this same PR promoted in Commands and CI) and
    `STANDARDS.md` described `build.yml` with `build` only.
- Re-paste on: — (scaffold).
- **Issue premises corrected (C2):**
  - The issue asks for pin `@profile-as-code/cli@0.2.0`; the repo **already** pinned
    `0.3.0` since PR #14 (required by the M7 schema). `CONTRIBUTING.md` documents
    the real pin.
  - The SHA the review comment gave for `setup-node` (`11bd7190…`) is actually an
    `actions/checkout` commit (`v4.2.2`): pinning `setup-node` with that value does
    not resolve the action. The ones above come from
    `gh api repos/<owner>/<repo>/git/ref/tags/<ref>`.
- Verified 2026-10-12 (engine `@profile-as-code/cli@0.3.0` from npm): `validate`
  exit 0 (schema valid · drift 0 · geo 81/100) · `check` exit 0 (registry 0 findings
  · media 0 findings) · 12 `content/*.yaml` and **2 workflows** parse · `.pascorc`
  valid JSON with `tagPattern: "v*"` · `diff` probe with both patterns (above) ·
  link gate: 11 tracked `.md` resolve, and it fails (exit 1) on a broken fixture, in
  a mixed batch and on staged generated markdown, while passing on a file without
  links and on one with only external links/anchors · bot guard: `false` proceeds,
  `true` skips, missing ⇒ exit 1 (fail-closed) · empty array under
  `set -euo pipefail` does not break the step · **3 workflows** parse · the gate
  self-test ran verbatim and was probed against a neutralized gate (fails as it
  should) · the hardened regex was tested on the 4 new cases (`"title"`, `<>`,
  `#frag`, name with spaces).

## 2026-10-12 — evidence-registry scaffold: media/ + packs + examples (issue #8, D17/§18)
- What changed:
  - **`media/`** with `certificates/`, `photos/`, `press/` + `media/README.md`: what
    belongs there (small and versionable), limits (>50 MB warn, 100 MB GitHub hard
    limit), the **no-hot-link rule** (media reaches the public only through
    `media/ → assets/ → deploy`) and the `PASCO_EVIDENCE_ROOT` alternative.
  - **`docs/evidence-packs.md`** — per-domain checklists (designer, filmmaker,
    scientist, engineer) mapped to the schema's real kinds + expected metadata.
  - **`docs/power-user-symlinks.md`** — symlink/stow: git stores the *text* of the
    link, absolute targets break CI and fresh clones; never the canonical mechanism.
  - **`content/credentials.yaml` + `content/artifacts.yaml`** — examples that
    **validate today** (the M7 schema is already deployed) + commented examples of
    `visibility: private` and `locator.path`.
  - **`README.md`** — evidence-flow section: claim ≠ credential ≠ artifact, how to
    add an entry, locator matrix, visibility and PII rules.
  - **`CHECKLIST.md`** — pre-deploy evidence gate: `credential-expiry`,
    `no-private-in-public-output`, resolvable `verifyUrl`, `media-missing-workspace`,
    `media-oversize`, `media-symlink-external`, checksums and asset verification.
  - **`AGENTS.md`** — map + rule 8 (registry naming + no-hot-link rule).
  - **Engine pin `0.2.0` → `0.3.0`** (README, `AGENTS.md`, `build.yml`) —
    **required**: the `credentials`/`artifacts` blocks and the M7/M8 checks only
    arrive in schema v1.4+, absent in 0.2.0 ([OFICIAL] registry.npmjs.org,
    `@profile-as-code/cli` dist-tags `latest: 0.3.0`, verified 2026-10-12).
- Re-paste on: — (scaffold).
- Verified 2026-10-12 against engine v0.3.0 from the monorepo: `validate` exit 0
  (schema valid · drift 0 · geo 81/100) · `check` exit 0 (registry 0 findings ·
  media 0 findings) · `check` **fails** correctly in a test workspace with an
  expired credential (`credential-expired`, warn) and with a missing media `path`
  (`media-missing-workspace`, error) · `build github-readme` bundles
  `assets/<id>/<basename>` + `manifest.json` with sha256 · loader OK in all 4 cases
  (absent / empty / `null` / comments-only file) · `hasCredential` JSON-LD emitted.
- **Scope note:** the issue assumed items 5–6 should stay commented out awaiting M7;
  M7 is already merged and published, so the examples ship **live and validated**.
  The issue's open point (the loader must skip absent/empty files) is **verified as
  resolved** in the current engine.
- **Review round (same branch):** three fixes where the prose did not match the
  engine's real behaviour, all three reproduced before fixing:
  - **`unlisted` is not a sharing mode** — it is indistinguishable from `private`
    for the gate: wiring an `unlisted` credential from a claim **fails** with
    `check/private-in-public-output` (exit 1). README, `docs/evidence-packs.md` and
    CHECKLIST sold it as "shared on request" and even recommended it.
  - **The evidence gate ran nowhere** — `build.yml` only did `validate` + `build`,
    and it has no `pull_request` trigger, so `pasco check` could never block a PR.
    New `evidence` job in `checks.yml` (PR-triggered) that installs the engine and
    runs `validate` + `check`.
  - **The "add a credential" recipe omitted the `id` consequence** — referencing an
    id that does not exist fails `validate` with `dangling cross-ref` (exit 1),
    exactly the error the docs described a page away. The recipe now declares the
    wiring step as such, with the existing-`id` + `visibility: public` requirement.
  - Also: the 4 missing `media-*` codes in the CHECKLIST (`media-path-unsafe`,
    `media-not-a-file`, `media-external-missing`, `media-unbundled-no-id`, all four
    reproduced), the `sha256:0000…` placeholder replaced by a `shasum -a 256`
    instruction (the placeholder passed `validate` but broke `check` as soon as the
    entry was public), `.gitkeep` as a cleanup item, and a clarification that
    **`press[]` is brand-only** (the template is flavor `person`: a write-up goes as
    an artifact of `document`).
- Round verification: `validate` + `check` exit 0 with the **published** CLI
  (`@profile-as-code/cli@0.3.0` from npm — the artifact CI runs, not the monorepo) ·
  6 failure injections reproduced · both workflows parse as YAML (the repo already
  had a `startup_failure` from uncommented prose) · fresh clone verified.

## 2026-10-10 — engine pin (published 2026-10-09) + build R2 workflow (issue #11)
- What changed: the README stops telling you to build the engine from the monorepo —
  the real package is **`@profile-as-code/cli@0.2.0`** (`pasco` is the bin) and the
  template pins it; terminal-free start (edit `content/` in the browser). New
  `.github/workflows/build.yml` (R2 of `profile-as-code#122`): `validate` + `build`
  from npm (node 22, the engine minimum) commits `profiles/` in your workspace; in an
  `is_template` repo the bot does not push to `main` (declared exception to rule 6).
  AGENTS.md: map + pin. Drift fixed: `profiles/github-profile/` →
  **`profiles/github-readme/`** (`CHECKLIST.md`, `profiles/README.md`).
- Re-paste on: — (scaffold).
- Verified 2026-10-10 with the pinned engine: `validate` exit 0 (schema valid ·
  drift 0 · geo 81/100) · deterministic `build` · yaml + links OK.
- **Out of this PR** (hard stop D5): CONTRIBUTING + template release → #12.

## 2026-09-15 — identity.email migration (v1.5/#71) + `.pascorc` rename (#38)
- What changed:
  - **Email as a fact (v1.5, issue #71, engine PR #72):** the Alex Rivera example
    carries `email: alex@example.com` at the root of `identity` — the
    `platform: email` row with `mailto:` is removed from `links[]` (PR #64's
    `^https?://` scheme boundary rejects it: every cloned workspace failed
    `pasco validate` on day one).
  - **Rename `.pacrc` → `.pascorc`** (issue #38: bin `pac` → `pasco`) — the current
    CLI rejects the legacy `.pacrc`; the scaffold renews it.
  - README + `profiles/README.md`: `pac` → `pasco` commands.
- Re-paste on: — (scaffold; users re-clone or apply the same change in their
  workspace: email row in links[] → root `email:`).
- Verified: `pasco validate` (engine PR #72) schema OK · drift 0 · YAML CI OK.

## 2026-09-15 — D18 adoption: origin stamps + ids + ledger stub (issue #7)
- What changed: example rows in `experience/projects/publications` carry a stable `id`
  (`exp-example-*`, `proj-example-*`, `pub-example-*` — trackable by `pasco status`) and
  `origin: template` (D18 §19.2 provenance — absent = user-authored). Empty stub
  `content/deployments.yaml` (per-entry ledger — only `pasco` writes). README: the
  `pasco status --mark <ledgerKey> <surface>` confirmation step in the deploy flow +
  the corrected CLI command `pac` → `pasco` (naming drift: the real bin is `pasco`).
  CHECKLIST.md: transition note to the AUTO-GENERATED view (`--write-checklist` overwrites).
- Re-paste on: — (not applicable; template scaffold)
- Verified: `pasco validate` exit 0 (schema v1.3) · `pasco status` — 6 tracked units
  `[template]`, 0 untracked, 0 stale · yaml parse OK · links OK

## 2026-09-07 — README: per-user workspace = `profile-data-<username>` + gh bootstrap
- What changed: start guide aligned to the engine's canonical terminology (SPEC §9.1,
  per-user naming): the workspace is called `profile-data-<username>` (owner in the
  name, family prefix wins). Recommended CLI-first path: `gh repo create
  profile-data-<username> --template … --private` (creates it private directly). README
  H1 fixed to `profile-data-template` (drift from the PR #3 rename).
- Re-paste on: — (not applicable; template docs)
- Verified: relative links OK + yaml parse OK — CI `checks.yml` green (run 34159636684,
  the repo's first successful run).

## 2026-08-08 — workspace init
- What changed: initial template with a fictional example persona.
- Re-paste on: — (no deploy yet)
- Verified: —

## 2026-08-11 — profile-* family: rename to profile-data-template
- What changed: the template is renamed to **profile-data-template** (and the user's
  workspace to **profile-data**) — "profile" first: alphabetical grouping, one mental
  model with the engine (profile-as-code). Fork instruction updated: rename the fork to
  `profile-data` and make it private.
- Re-paste on: — (not applicable; naming)
- Verified: repos renamed on GitHub (old URLs redirect).

## 2026-08-10 — v1 contract conformance (engine's first e2e test)
- What changed: data aligned to schema/profile.schema.json v1 (M1): file = root property
  (no key wrapper), identity.links as an array of {platform,label,url}, YYYY-MM-DD dates,
  highlights as a per-language string, platformWeights 0..1, projects.links as an array,
  evidence {claim,source,verified}, headlines in their own file, `.pacrc` JSON
  ({workspace,defaults,diff}). Honest GEO anchors (real reinforcement).
- Re-paste on: — (no deploy yet)
- Verified: `pac validate` exit 0 (valid schema, drift 0, geo 84/100);
  `pac build` renders base texts in en/es.
