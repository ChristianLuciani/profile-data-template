# Roadmap

What is planned for this scaffold, and what is deliberately out of scope. Short
on purpose: the authoritative list of **open** work is the issue tracker — this
file explains direction, so someone arriving cold knows where to contribute.

## Where we are

- **v0.3.2** is the current release (engine `@profile-as-code/cli@0.3.7`): the pin
  became single-source — `check-engine-pins.sh` plus a `pins` job in `checks.yml`
  — and the per-repo maintenance ledger stopped dirtying the tree.
- **v0.3.1** moved the pin to engine
  `@profile-as-code/cli@0.3.7` (the `latest` on npm, verified 2026-10-31 —
  [OFICIAL] [WEB: registry.npmjs.org]). It declared
  `"engine": "0.3.7"` in `.pascorc`, added the manual `preview` workflow and
  documented the tree the pin actually renders.
- **v0.3.0** was the first tagged release (engine `0.3.0`).
- The per-surface paste artifacts and the variant body store are **shipped**:
  profile-as-code #239 landed in engine `0.3.5` and #238 in `0.3.6`, so both
  apply to the current pin — `profiles/README.md` documents them.

## Next release

The template version mirrors the engine line (`CONTRIBUTING.md` § Releases):
the current engine line is `0.3.x` (no `0.4` release is announced), so the
scaffold moves by engine `0.3.x` patches and its own revisions.

The next scaffold tag is **`v0.3.3`**, for a docs-only or single-surface fix on
this line. When a new engine patch lands, in this order:

1. bump the pin in all of its surfaces — the authoritative list is in
   `CONTRIBUTING.md` § Releases (`.pascorc` → `engine` included);
2. update the generated tree in `profiles/README.md`: `profiles/<platform>.md`
   appears only for a manual surface that has a bio row, and the tree moves
   **with** the pin, in the same PR;
3. cut the tag on the merge commit and publish the release.

## Deliberate non-goals

- **No `examples/` directory.** This repository *is* the example: `content/`
  holds a fictional persona that validates end to end. A real profile cannot be
  published here — a fork is user data, private by design.
- **No CodeQL / code scanning.** There is essentially no code to analyze — YAML
  and Markdown. The gates that matter are the data and text checks (`pasco
  validate` + `pasco check`), link resolution, the fictional-data guard and the
  secret scan.
- **No service-level promise.** One maintainer, best effort. Security reports go
  through `SECURITY.md`, never a public issue.

## How to propose work

- Bug in this template (docs, CI, example data) → the
  [bug form](.github/ISSUE_TEMPLATE/bug.yml).
- A proposal that helps every user → the
  [feature form](.github/ISSUE_TEMPLATE/feature.yml), opened **before** a large
  PR.
- A bug in the engine (`pasco`, schema, renderers) →
  [profile-as-code issues](https://github.com/ChristianLuciani/profile-as-code/issues).
