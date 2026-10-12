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
| `.github/workflows/` | `checks.yml` (offline) · `build.yml` (`pasco` from npm) |
| `.github/scripts/check-links.sh` | Relative-link gate shared by `checks.yml` and `build.yml` (one copy, two callers) |
| `.pascorc` | Engine CLI config (`pasco`): `workspace`, `defaults` (lang, variants), `diff` (`tagPattern`) |
| `CHECKLIST.md` | Post-deploy verification per platform |

## Rules for agents

1. **Facts are sacred.** Never invent, guess, or "improve" a fact in
   `content/*.yaml`. Unsure → mark `[?]` and ask. GEO: an LLM cross-referencing
   profiles must find identical facts everywhere.
2. **Source at the source.** A drift between `content/` and `profiles/` is fixed
   by regenerating the output, not by editing the output by hand.
3. **Validate before commit.** `content/*.yaml` must parse and match the engine
   schema. The engine is pinned: `@profile-as-code/cli@0.3.0` (README +
   `build.yml`); run `pasco validate` + `pasco build` and commit `profiles/`.
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

## Commands

```bash
# YAML parse only (no engine)
python3 -c "import yaml,glob; [yaml.safe_load(open(f)) for f in glob.glob('content/*.yaml')]; print('yaml OK')"

# pinned engine: schema + drift/geo, the §18.8 evidence gate, generated views
npx -y @profile-as-code/cli@0.3.0 validate
npx -y @profile-as-code/cli@0.3.0 check
npx -y @profile-as-code/cli@0.3.0 build
```

## Context discipline

This workspace is small by design — `content/` + `profiles/` + this doc is the
whole surface. Read the relevant YAML file, not the whole tree, and never dump
large files into context without a filter.
