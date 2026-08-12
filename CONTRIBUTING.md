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
| CI / validation | `.github/workflows/` | YAML parse + link checks |

## Ground rules

1. **Never push to `main`.** Branch + PR; the maintainer merges.
2. **Evidence rule.** Quantitative claims (platform limits, character counts…)
   carry a source + verification date (`[OFICIAL]`/`[EXPERTO]`/`[BENCHMARK]`/`[?]`).
3. **The template must validate.** `content/*.yaml` parses and matches the
   profile-as-code schema (run its schema-check if you change structure).
4. **No real personal data.** Keep example content realistic but generic — a
   user's real data belongs in their own (private) fork.
5. **Forkers update the copyright.** When you fork this template for your own
   `profile-data`, replace the `Copyright (c)` line in `LICENSE` with your name.

## Local setup

This is a data workspace, not an app — no build. Validate YAML:

```bash
python3 -c "import yaml,sys,glob; [yaml.safe_load(open(f)) for f in glob.glob('content/*.yaml')]; print('yaml OK')"
```

For schema validation, clone the engine ([profile-as-code](https://github.com/ChristianLuciani/profile-as-code))
and run its `scripts/schema-check/check.py` against this workspace.
