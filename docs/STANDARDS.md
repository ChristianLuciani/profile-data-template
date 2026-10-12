# Standards — profile-data-template

Standards for this repo and for every workspace forked from it. The engine
([profile-as-code](https://github.com/ChristianLuciani/profile-as-code)) is the
contract owner; this repo is the data scaffold.

## Evidence rule

Every quantitative claim in this repo (platform character limits, official
lengths, dates) carries a source + verification date:
`[OFICIAL]` / `[EXPERTO]` / `[BENCHMARK]` / `[?]`. No source, no entry. This
extends to example `content/` values that cite platform constraints.

## Data conventions

- **YAML is the source of truth.** `content/*.yaml` holds facts (deterministic,
  validated) and texts (per-platform variants). Structure follows the
  profile-as-code schema v1 (contract owner).
- **GEO consistency.** Facts must be identical across platforms — an LLM that
  cross-references profiles must find the same facts (see `CHECKLIST.md`).
- **i18n.** Data is bilingual by design (`en` essential, `es` native). Repo
  *docs* are English (D8).
- **Drift-check.** `profiles/` outputs derive from `content/`; a mismatch is a
  bug to fix at the source, not the output.

## Privacy

- **Private by default.** A forked workspace holds personal data; keep the repo
  private (repo-governance of the profile-* family).
- **No real data in the template.** Example content is realistic but generic.

## Repository hygiene

- Never push to `main`; branch + PR; the maintainer merges. **Declared
  exception:** in a workspace created from this template, `build.yml` commits
  generated `profiles/` to `main` as `github-actions[bot]` — that is its job
  (R2 on-ramp). It never does so in this template repo itself: the `is_template`
  guard is fail-closed, so a missing flag refuses to commit rather than pushing
  blind (`CONTRIBUTING.md` § CI).
- Docs in English; comments when present.
- CI: `checks.yml` (content **and workflow** YAML parse · relative markdown
  links · `pasco validate` + `check`) and `build.yml` (`pasco build`, then
  commits `profiles/`).
- Claims change → update source + date, never silently.
