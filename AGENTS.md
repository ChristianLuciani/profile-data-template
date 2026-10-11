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
| `content/bios.yaml` · `headlines.yaml` · `positioning.yaml` | Per-platform texts, variant-based |
| `content/skills.yaml` · `keywords.yaml` | Skills + SEO-ish keywords |
| `profiles/` | Rendered per-platform outputs (README, LinkedIn…) |
| `.github/workflows/` | `checks.yml` (offline) · `build.yml` (`pasco` from npm) |
| `.pascorc` | Engine CLI config (`pasco`): lang, variants, diff tag |
| `CHECKLIST.md` | Post-deploy verification per platform |

## Rules for agents

1. **Facts are sacred.** Never invent, guess, or "improve" a fact in
   `content/*.yaml`. Unsure → mark `[?]` and ask. GEO: an LLM cross-referencing
   profiles must find identical facts everywhere.
2. **Source at the source.** A drift between `content/` and `profiles/` is fixed
   by regenerating the output, not by editing the output by hand.
3. **Validate before commit.** `content/*.yaml` must parse and match the engine
   schema. The engine is pinned: `@profile-as-code/cli@0.2.0` (README +
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

## Commands

```bash
# YAML parse only (no engine)
python3 -c "import yaml,glob; [yaml.safe_load(open(f)) for f in glob.glob('content/*.yaml')]; print('yaml OK')"

# pinned engine: schema + drift/geo + generated views
npx -y @profile-as-code/cli@0.2.0 validate
npx -y @profile-as-code/cli@0.2.0 build
```

## Context discipline

This workspace is small by design — `content/` + `profiles/` + this doc is the
whole surface. Read the relevant YAML file, not the whole tree, and never dump
large files into context without a filter.
