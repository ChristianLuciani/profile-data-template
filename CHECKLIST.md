# CHECKLIST — per-platform post-deploy verification

[Español](CHECKLIST.es.md)

> **State of this file (D18, SPEC §19 of the engine):** per-entry deploy state lives in
> `content/deployments.yaml` — report it with `pasco status`. Once you start confirming
> pastes with `pasco status --mark <ledgerKey> <surface>`, the ledger is the source of
> truth: `pasco status --write-checklist` **overwrites** this file with its
> AUTO-GENERATED view (in English). From that point on, do not edit it by hand. Until
> then, the lists below are your manual post-paste verification.
>
> **Translation note:** `CHECKLIST.es.md` is a hand-maintained Spanish translation of the
> manual checklist. The engine only regenerates `CHECKLIST.md`, and the generated view
> is not the manual checklist — the Spanish file cannot mirror it, so re-sync it by hand
> or retire it after you run `--write-checklist`.

After pasting/updating a platform, verify and mark it. Factual consistency across
platforms IS your citability (GEO): if an LLM cross-references two profiles and finds
contradictions, it drops you.

## Before publishing your fork — repository privacy

This is not post-paste: it is the **workspace** privacy gate. In the template
(`profile-data-template`) it holds by design; in your copy it is yours.

- [ ] **The repo has been private since before you loaded data.** If you created it
      public, switch it to private *and* assume what was published may already be indexed.
- [ ] **`git status` shows no `.pasco/`, `.env*` or `media/` bytes** — local state and
      binaries are gitignored, not committed.
- [ ] **No raw link to a file in a private repo** in `profiles/`
      (`raw.githubusercontent.com/...`): the asset travels through `assets/`, never as a URL.
- [ ] **Secret scanning + push protection enabled** (Settings → Code security).
      A token pasted once stays in history even if you delete it afterwards.
- [ ] **Someone else's data is not here.** `content/identity.yaml` describes the person
      publishing, not a client or former employer without permission.
- [ ] **`LICENSE` carries your copyright**, not the template's.
- [ ] If you are working in **this** template: `bash .github/scripts/check-example-data.sh`
      (in your fork the CI job skips and the script fails on purpose, because your
      identity stops being the example).

## Evidence (D17, SPEC §18) — before any deploy

This is **not** post-paste: it is the gate before deploying. `pasco check` executes the
rules (M7/§18.8 and M8/§18.6 are implemented; requires CLI ≥ 0.3.0). The names in
parentheses are the codes the CLI emits in the finding.

`validate` + `check` also run automatically on every PR
(`.github/workflows/checks.yml`, job `evidence`) — but the job only covers what the
engine knows how to verify. The manual items below are still yours.

- [ ] **`pasco check` exits clean or with understood warnings** — an error blocks the deploy.
- [ ] **`credential-expiry`** (`check/credential-expired`) — no credential with
      `expires` in the past. The check names the credential and index; renew the data or
      update `expires`. Renew once a year, not when someone points it out.
- [ ] **`private-in-public-output`** (`check/private-in-public-output`) — nothing
      `unlisted` **or** `private` referenced from public material. Only `public` counts
      as public: `unlisted` fails just like `private`. If it fires, set the entry to
      `public` or drop the reference.
      *This check FAILS the build (exit 1) — it is an error, not a warning.*
- [ ] **`dangling-cross-ref`** (`pasco validate` reports it) — every `credentialId` /
      `artifactId` / `artifactRefs` points at an `id` that **exists** in its block. An id
      that does not exist fails the load (exit 1); it is not ignored.
- [ ] **`verifyUrl` resolves** — open every `verifyUrl` of `public` credentials: it is the
      link a skeptic will click. A 404 undoes more than the credential adds.
- [ ] **`media-missing-workspace`** (error) — every `path: media/…` exists in the repo.
      The workspace is the SSOT: if the file is missing, it is an error and the asset is
      not bundled.
- [ ] **`media-path-unsafe`** (error) — no locator resolves **outside** its base
      (workspace or evidence root). A `media/../../..` is a containment error, not a valid path.
- [ ] **`media-not-a-file`** (error) — every locator points at a **file**, not a
      directory. `media/photos/` as a locator fails.
- [ ] **`media-oversize`** (warn) — no file > 50 MB versioned (GitHub blocks at 100 MB).
      For large files: git-lfs or a `url` locator.
- [ ] **`media-checksum-mismatch`** (error) — declared checksums match the bytes. Applies
      to immutable artifacts (datasets, documents): if the file changed, the promise broke.
      For mutable media, omit `checksum`.
- [ ] **`media-symlink-external`** (warn) — if it appears, the render depends on your
      machine. Declare a `checksum` or migrate to `PASCO_EVIDENCE_ROOT`
      (see `docs/power-user-symlinks.md`).
- [ ] **`media-external-missing`** (warn) — expected and benign in CI: a runner without
      `PASCO_EVIDENCE_ROOT` skips external assets and renders without them. If you see it
      **on your machine**, check that the env var is set in that shell.
- [ ] **`media-unbundled-no-id`** (warn) — a `path` locator without an `id` cannot get a
      stable target (`assets/<id>/…`). Add `id` if you want the media bundled.
- [ ] **`.gitkeep` cleaned up** — when you add the first real file to a `media/`
      subdirectory, delete its `.gitkeep` (it exists only so git versions the empty directory).

### Bundled-media verification (only with `path` locators)

- [ ] **`pasco build <platform>` bundled assets/** — `profiles/<platform>/assets/` exists and
      `assets/manifest.json` records id, target, sha256 and bytes per asset.
- [ ] **`assets/…` links resolve on the public surface** — deploy-relative: they only work
      **after** `assets/` was committed to the deploy repo. An `assets/…` that does not
      resolve = the commit did not include the binaries.
- [ ] **No `media/` file was pasted as a raw URL** — not a `raw.githubusercontent.com` link
      to a private repo, not a local absolute path. For the world they are 404s.

## GitHub (profile README)
- [ ] README updated via git/API (commit in profiles/github-readme)
- [ ] Facts (role, dates, papers) identical to the rest of the platforms
- [ ] Pinned projects = the 3-6 you want to show
- [ ] Links to every profile (sameAs)

## LinkedIn
- [ ] Headline ≤ official limit (see the skill) and coherent with positioning.statement
- [ ] About pasted and reviewed (variant chosen in `active`)
- [ ] Skills ordered by weight (platformWeights)
- [ ] Featured: projects + publications (resolvable DOIs)
- [ ] Experience dates identical to GitHub/web

## Upwork
- [ ] Title/overview pasted (EN-first) and coherent with audience.clients
- [ ] Specialties and skills correct (platformWeights upwork)
- [ ] Portfolio connected to active projects
- [ ] Rate/availability coherent (does not contradict the rest)

## X
- [ ] Bio ≤ official limit; semantic anchors present without stuffing
- [ ] Pinned: the post a new visitor should see

## ResearchGate
- [ ] Publications synchronized (resolvable DOI, ORCID)
- [ ] Bio and skills coherent

## Substack
- [ ] Profile: bio + sections + featured coherent
- [ ] Citable newsletter (visible RSS, linked from the other profiles)
