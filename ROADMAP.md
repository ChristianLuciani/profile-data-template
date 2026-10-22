# Roadmap

What is planned for this scaffold, and what is deliberately out of scope. Short
on purpose: the authoritative list of **open** work is the issue tracker — this
file explains direction, so someone arriving cold knows where to contribute.

## Where we are

- **v0.3.0** is the first tagged release, cut for engine
  `@profile-as-code/cli@0.3.0`.
- `main` already carries work merged after that tag (the generated-artifact tree
  fix, OSS readiness, CI hardening and Dependabot pins). The next tag picks it
  up — see *Next release*.

## Next release

The template version mirrors the engine line (`CONTRIBUTING.md` § Releases).

The next release tracks **engine 0.4**, which consolidates the per-surface paste
artifacts (profile-as-code #239) and the variant store (#238). When that engine
release exists, in this order:

1. bump the pin in its five surfaces — the authoritative list is in
   `CONTRIBUTING.md` § Releases;
2. update the generated tree in `profiles/README.md`: the
   `profiles/<platform>.md` files appear for manual surfaces that have a bio row.
   The tree moves **with** the pin, in the same PR;
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
