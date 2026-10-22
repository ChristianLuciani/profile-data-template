# AGENTS.md — profile-data (template)

Instructions for AI agents working in this workspace. Humans: see `CONTRIBUTING.md`
and `CHECKLIST.md`.

## What this is

A forkable **data workspace** for the profile-* family: your professional
identity as code. Facts and texts live in `content/*.yaml`; per-platform
outputs live in `profiles/`; the engine
([profile-as-code](https://github.com/ChristianLuciani/profile-as-code)) reads
this workspace by path — it never copies your data.

If you are working on a forked copy, treat it as **real user data**: private,
accurate, and the user's responsibility.

## Map

| Where | What |
|---|---|
| `content/identity.yaml` | Core identity facts (name, role, contact) |
| `content/experience.yaml` · `projects.yaml` · `publications.yaml` | History, evidence-backed |
| `content/credentials.yaml` · `artifacts.yaml` | Evidence registry — third-party attestations + works (D17/§18, optional) |
| `content/bios.yaml` · `headlines.yaml` · `positioning.yaml` | Per-platform texts, variant-based |
| `content/skills.yaml` · `keywords.yaml` | Skills + SEO-ish keywords |
| `media/` | Versioned small binaries (`certificates/`, `photos/`, `press/`) — bundled to `profiles/<platform>/assets/` |
| `docs/evidence-packs.md` · `docs/power-user-symlinks.md` | Per-domain proof checklists · stow/symlink tradeoffs |
| `profiles/` | Rendered per-platform outputs (README, LinkedIn… + `assets/` when media is bundled) |
| `.github/workflows/` | `checks.yml` (yaml · links · example-data · secrets · evidence) · `workflow-lint.yml` (offline) · `build.yml` (`pasco` from npm) |
| `.github/scripts/` | `check-links.sh` (shared by `checks.yml` and `build.yml`) · `check-example-data.sh` (template privacy guard) |
| `.github/ISSUE_TEMPLATE/` · `PULL_REQUEST_TEMPLATE.md` | Issue forms (bug/feature) + PR privacy/checklist |
| `.github/dependabot.yml` | Weekly SHA-pin updates for GitHub Actions |
| `.pascorc` | Engine CLI config (`pasco`): `workspace`, `defaults` (lang, variants), `diff` (`tagPattern`) |
| `CHECKLIST.md` | Post-deploy verification per platform (EN) · `CHECKLIST.es.md` (ES, hand-maintained) |
| `SECURITY.md` | Private disclosure policy — never a public issue |

## Rules for agents

1. **Facts are sacred.** Never invent, guess, or "improve" a fact in
   `content/*.yaml`. Unsure → mark `[?]` and ask. GEO: an LLM cross-referencing
   profiles must find identical facts everywhere.
2. **Source at the source.** A drift between `content/` and `profiles/` is fixed
   by regenerating the output, not by editing the output by hand.
3. **Validate before commit.** `content/*.yaml` must parse and match the engine
   schema. The engine is pinned: `@profile-as-code/cli@0.3.0` (the authoritative
   list of the surfaces that carry the pin is `CONTRIBUTING.md` § Releases); run
   `pasco validate` + `pasco check` + `pasco build`, and commit `profiles/`.
4. **i18n.** `en` essential, `es` native. Keep both in sync when editing texts.
5. **Privacy.** This is personal data — private repo, no screenshots/URLs in
   public artifacts, no real data in the template itself.
6. **Never push to `main`.** Branch + PR; the human merges. If it's a fork, keep it
   in sync with upstream. **In your own workspace** the `build.yml` bot is the
   declared exception: committing `profiles/` to `main` is its job (R2 on-ramp).
7. **Evidence rule.** Quantitative claims (limits, dates) carry source + date
   (`[OFICIAL]`/`[EXPERTO]`/`[BENCHMARK]`/`[?]`); epistemic notation
   `[MI]`/`[WEB]`/`[INF]`/`[?]` for inference vs. source.
8. **Registry naming is load-bearing.** `evidence[]` means *claims only*;
   `credentials[]` is third-party attestation; `artifacts[]` is a work/media item.
   Never call a credential or artifact "evidence" — publications/press keep their
   own blocks and reference registry ids via `artifactRefs`. Pointers only: the
   engine never owns the binaries, so a `media/…` path is the SSOT and reaches a
   public surface only through the renderer's `assets/` output — never as a raw
   URL. `visibility: private` material must never be referenced from public
   output; `pasco check` fails the build if it is.
9. **This repo is public; the data is not.** Never add real personal data, private
   media, tokens or machine paths here — run
   `bash .github/scripts/check-example-data.sh` before committing. `.pasco/` and
   `.env*` stay gitignored and untracked.
10. **Never flip visibility, create a release, or merge a PR.** Those are
    human-only actions (repo-governance §2). Prepare the branch and the PR;
    the maintainer decides.
11. **Keep the language pairs in sync.** A change to the start flow, layout or
    commands lands in `README.md` **and** `README.es.md`, and in `CHECKLIST.md`
    **and** `CHECKLIST.es.md`, in the same commit. The engine regenerates only
    `CHECKLIST.md` (English); the Spanish checklist is hand-maintained.
12. **Pin every action by full commit SHA** (40 chars + `# vX.Y.Z` comment).
    Dependabot updates pins; never replace one with a mutable tag.

## Commands

```bash
# YAML parse only (no engine)
python3 -c "import yaml,glob; [yaml.safe_load(open(f)) for f in glob.glob('content/*.yaml')]; print('yaml OK')"

# pinned engine: schema + drift/geo, the §18.8 evidence gate, generated views
npx -y @profile-as-code/cli@0.3.0 validate
npx -y @profile-as-code/cli@0.3.0 check
npx -y @profile-as-code/cli@0.3.0 build

# offline guards CI runs — cheap, run them before asking for review
bash .github/scripts/check-links.sh
bash .github/scripts/check-example-data.sh
```

## Context discipline

This workspace is small by design — `content/` + `profiles/` + this doc is the
whole surface. Read the relevant YAML file, not the whole tree, and never dump
large files into context without a filter.
