# Contributing to profile-data-template

This repo is the **scaffold** for a `profile-data` workspace — the per-user
private data repo of the profile-* family. The engine is
[profile-as-code](https://github.com/ChristianLuciani/profile-as-code); this
template is what every user forks to create *their own* data workspace.

Contributions are welcome when they help **every user of the family**, not just
one person's data.

## What you can contribute

| Area | Where | Notes |
|---|---|---|
| Instructions / start flow | `README.md` | The "<10 min start" must stay true end-to-end |
| Post-deploy checklist | `CHECKLIST.md` | Per-platform verification (GEO consistency) |
| Example content | `content/` | Realistic-but-generic YAML that validates against the schema |
| Docs & translations | `docs/`, README | English primary (D8); the *data* is bilingual by design |
| CI / validation | `.github/workflows/`, `.github/scripts/` | YAML parse + link checks + the evidence gate |

## Ground rules

1. **Never push to `main`.** Branch + PR; the maintainer merges. This is the
   rule for *this* repo (the scaffold). In a **user's** workspace the
   `build.yml` bot is the declared exception — committing generated `profiles/`
   to `main` is its job. See *CI* below and `docs/STANDARDS.md`.
2. **Evidence rule.** Quantitative claims (platform limits, character counts…)
   carry a source + verification date (`[OFICIAL]`/`[EXPERTO]`/`[BENCHMARK]`/`[?]`).
3. **The template must validate.** `content/*.yaml` parses and matches the
   profile-as-code schema — run `pasco validate` (see *Local setup*).
4. **No real personal data.** Keep example content realistic but generic — a
   user's real data belongs in their own (private) fork.
5. **Forkers update the copyright.** When you fork this template for your own
   `profile-data`, replace the `Copyright (c)` line in `LICENSE` with your name.

## Local setup

This is a data workspace, not an app — it has no build of its own. The engine is
pinned: **`@profile-as-code/cli@0.3.0`** (`pasco` is the bin). The pin is mirrored
in the files that must be bumped together — `README.md`, `AGENTS.md`, this one,
and both workflows. (A `CHANGELOG.md` entry names the pin as *history*, not as a
surface to edit.) The *Releases* section below carries the authoritative list.
Source: `registry.npmjs.org` `@profile-as-code/cli` dist-tag `latest`
([OFICIAL] [WEB: registry.npmjs.org, verified 2026-10-12]).

```bash
# 1. YAML parse only — offline, no engine, ~seconds
python3 -c "import yaml,glob; [yaml.safe_load(open(f)) for f in glob.glob('content/*.yaml')]; print('yaml OK')"

# 2. the pinned engine (needs node 22+, the engine's minimum)
npm i -g @profile-as-code/cli@0.3.0

# 3. schema + drift/geo, then the evidence/media gate (§18.8 of the engine SPEC)
pasco validate         # schema violations FAIL (exit 1); drift/GEO WARN (exit 0)
pasco check            # expiry, privacy, media transport — the pre-deploy gate

# 4. regenerate the committed output
pasco build
```

The engine is **read-only** over this workspace, with two exceptions that write
into `content/` only: `pasco refine` (the variant you pick) and
`pasco status --mark` (the deploy ledger, D18).

### Never edit `profiles/` by hand

`profiles/` is **generated output** and it *is* committed — it is the deploy
artifact. A hand edit is drift that the next `pasco build` overwrites. Fix the
wrong output at its source in `content/`, then regenerate:

```bash
pasco build
git diff profiles/     # exactly what changed
```

`content/` is the single source of truth; `profiles/` derives from it. This is
the same rule as ground rule 2 in `AGENTS.md`.

## CI

Two workflows, both installing the pinned engine from npm:

| Workflow | Trigger | What it does |
|---|---|---|
| `.github/workflows/checks.yml` | every push to `main` + every PR | `yaml` — `content/*.yaml` **and** `.github/workflows/*.yml` parse · `links` — relative markdown links resolve · `evidence` — `pasco validate` + `pasco check` |
| `.github/workflows/build.yml` | push to `main` touching `content/**`, `.pascorc` or itself; manual dispatch | `pasco validate` + `check` + `build`, then commits `profiles/` |

Three things about `build.yml` are worth knowing before you touch it:

- **It commits `profiles/` as `github-actions[bot]` in user workspaces — never
  in this template repo.** The discriminator is the repository `is_template`
  flag and the guard is **fail-closed**: if the flag is missing from the event
  payload the bot refuses to commit instead of pushing blind. (The flag itself
  lives in *Settings → Template repository* and is flippable by the owner; that
  residual is declared, not hidden.)
- **Its push does not trigger `checks.yml`.** GitHub does not run workflows for
  events raised by `GITHUB_TOKEN` ([OFICIAL] [WEB: docs.github.com, "Triggering
  a workflow"]), so the markdown it generates would never be link-checked.
  Instead `build.yml` runs the link check itself, before committing, through
  **`.github/scripts/check-links.sh` — the same script `checks.yml` uses.** One
  copy of the logic, two callers; a second copy would drift.
- **The job holds `contents: write`**, so its actions are pinned by commit SHA
  instead of a mutable tag.

## Releases

A release is an **annotated git tag on `main`**, plus the matching entry at the
top of `CHANGELOG.md`.

**Version scheme — the template mirrors the engine pin.** `MAJOR.MINOR` follows
the `@profile-as-code/cli` version the scaffold expects; `PATCH` is the
scaffold's own revision within that engine line. So `v0.3.0` is the first
scaffold release for engine `0.3.0`, and a docs-only fix that keeps engine
`0.3.0` is `v0.3.1`. The point: a fork reads its engine compatibility straight
off the tag. The declared tradeoff is that the two cycles are coupled — a
template-only change still has to name which engine line it belongs to.

`.pascorc → diff.tagPattern` is **`v*`** so that `pasco diff` finds these tags.
The engine's default is `release-*`; with a `v*` tag and the default pattern,
`pasco diff` silently matches nothing and diffs against the first commit
instead (verified against engine 0.3.0).

Cutting a release:

1. Bump the pin in all of its surfaces (`README.md`, `AGENTS.md`,
   **this file**, `.github/workflows/checks.yml`, `.github/workflows/build.yml`)
   if the engine version changed, and bump `.pascorc` only if the tag convention
   changed.
2. Add the entry at the top of `CHANGELOG.md`, headed
   `## vX.Y.Z — YYYY-MM-DD — <title>` (older entries predate the first tag and
   keep their dated headings).
3. Merge the PR — the release commit is the **merge commit**.
4. Tag `main` at that merge commit and push the tag:

   ```bash
   git tag -a vX.Y.Z <merge-sha> -m "profile-data-template vX.Y.Z (engine @profile-as-code/cli@X.Y.Z)"
   git push origin vX.Y.Z
   ```

**Re-syncing a fork.** A fork or a "Use this template" copy does **not** follow
upstream on its own. A git fork inherits the tags; a `--template` copy (the
bootstrap the README recommends) starts as a single fresh commit with no tags
and no upstream remote, so for it the anchor is the top entry of `CHANGELOG.md`
and it must add the remote before it can compare anything:

```bash
git remote add upstream https://github.com/ChristianLuciani/profile-data-template
git fetch upstream --tags
git ls-remote --tags upstream           # where upstream is, and which tags exist
# diff your current state against an upstream release, scaffold paths only —
# correct whether or not you have the tag locally:
git diff HEAD upstream/vX.Y.Z -- README.md CONTRIBUTING.md docs/ .github/
```

Never merge an upstream release over `content/` — that directory is *your* data.
Take the scaffold (docs, CI, schema-facing examples) and leave the data alone.
