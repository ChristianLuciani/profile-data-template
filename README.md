# profile-data-template

> **Your professional identity as code.** A forkable data workspace for the
> [profile-as-code](https://github.com/ChristianLuciani/profile-as-code) engine:
> facts live in YAML, per-platform texts are rendered from them, and one source
> of truth keeps every profile consistent.

[![checks](https://github.com/ChristianLuciani/profile-data-template/actions/workflows/checks.yml/badge.svg)](https://github.com/ChristianLuciani/profile-data-template/actions/workflows/checks.yml)
[![license: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![engine: 0.3.0](https://img.shields.io/badge/engine-%40profile--as--code%2Fcli%400.3.0-blue)](https://www.npmjs.com/package/@profile-as-code/cli)

**This repository is a template, not the engine.** It contains no application
code. You copy it, replace the fictional example with your own facts, and the
engine validates and renders the result.

| You want… | It lives in |
|---|---|
| This workspace layout, docs, CI | **this repo** |
| The `pasco` CLI, the schema, the renderers | [profile-as-code](https://github.com/ChristianLuciani/profile-as-code) |
| `schema/profile.schema.json` | [engine schema](https://github.com/ChristianLuciani/profile-as-code/blob/main/schema/profile.schema.json) |
| The engine SPEC (`§9` covers this template) | [engine docs/SPEC.md](https://github.com/ChristianLuciani/profile-as-code/blob/main/docs/SPEC.md) |
| Prior art / research notes | [engine docs/research/01-prior-art.md](https://github.com/ChristianLuciani/profile-as-code/blob/main/docs/research/01-prior-art.md) |

## Status

- Scaffold **v0.3.0**, tracking `@profile-as-code/cli@0.3.0` — the current
  `latest` on npm, verified 2026-10-21 ([OFICIAL] [WEB: registry.npmjs.org]).
- The example content is a **fictional persona** (Alex Rivera) that documents the
  schema. Do not put real data in this repository; your data belongs in your fork.
- Maintained on a best-effort basis. Issues and PRs are triaged; see
  [CONTRIBUTING.md](CONTRIBUTING.md).

## Why this exists

A profile is published in many places and each one drifts. This workspace makes
the facts the source of truth:

- **Facts** (dates, roles, projects, papers, DOIs) are deterministic, validated,
  and drift-checked — an LLM cross-referencing your profiles must find the same
  facts everywhere (GEO consistency).
- **Texts** (headlines, bios, angles) are generated per platform and per language
  (`en` essential, `es` native; `fr` is desirable), in variants you choose.
- **Evidence** is a first-class registry: claims, third-party credentials, and
  artifacts are different things and are named as such.
- **Deploy** is tracked: a ledger records what was pasted where, and whether it
  is still in sync with `content/`.

## Start in under 10 minutes — private first

> **Privacy rule #0:** create the repository **private before you write a single
> fact**. A public profile-data repo exposes your contact details, history and
> media. The CLI path below creates it private in one step.

1. Create your workspace from the template, private:

   ```sh
   gh repo create profile-data-<username> \
     --template ChristianLuciani/profile-data-template \
     --private
   ```

   Manual alternative: **Use this template** (or fork) on GitHub, then **rename it
   to `profile-data-<username>`** and make it **private**. The name carries the
   owner and the family prefix (canonical naming, engine SPEC §9.1).

2. Clone it:

   ```bash
   git clone git@github.com:<your-user>/profile-data-<username>.git
   cd profile-data-<username>
   ```

3. **You do not need to install the engine to get output.** In your copy,
   `.github/workflows/build.yml` installs the pinned `pasco` from npm and commits
   the generated `profiles/` on every push to `main` that touches `content/`.
   Edit `content/` in GitHub's web editor and the views appear.

   > Confirm **Actions** is enabled in your copy. You do **not** need to change
   > *Settings → Workflow permissions*: the workflow declares its own
   > `contents: write`. Check the **Actions** tab after the first push.

   For local runs, Node **22+** is required (engine `engines`):

   ```bash
   npm i -g @profile-as-code/cli@0.3.0
   ```

4. Replace the example in `content/` with your facts. Each file **is** its root
   property — `bios.yaml` is the `bios[]` array directly, with no wrapper key
   ([schema](https://github.com/ChristianLuciani/profile-as-code/blob/main/schema/profile.schema.json)):

   - `identity.yaml` — name, location, canonical links (the SSOT for your URLs)
   - `positioning.yaml` — positioning statement, audience angles, GEO anchors
   - `bios.yaml`, `headlines.yaml` — per platform, language and length
   - `skills.yaml`, `experience.yaml`, `projects.yaml`, `publications.yaml`, `keywords.yaml`

5. Validate and build:

   ```bash
   pasco validate         # schema FAILS (exit 1); drift/GEO WARN (exit 0)
   pasco check            # evidence registry + media transport gate
   pasco build            # deterministic per-platform output (no arg = all)
   pasco diff             # changes since the last release tag → CHANGELOG
   pasco refine linkedin  # PARTIAL: emits an agent task; --choose records the pick
   pasco status           # per-entry: origin · surfaces · in-sync/stale/never
   pasco status --write-checklist   # regenerates CHECKLIST.md from the ledger
   ```

6. **Deploy.** Paste each generated text into its platform (see
   [CHECKLIST.md](CHECKLIST.md)), or let git/API update your GitHub README and
   site. Record each paste so the ledger knows what is live:

   ```bash
   pasco status --mark experience:exp-example-labs linkedin
   # writes deployedAt + contentHash to content/deployments.yaml — only pasco writes it
   ```

7. **Version.** Every change ships with a `CHANGELOG.md` entry, so you know what
   to re-paste and where.

## What the engine writes

The engine is read-only over your workspace except for **four** commands — and
none of them rewrites your facts:

| Command | Writes |
|---|---|
| `pasco build` | `profiles/<platform>/` (+ bundled `assets/`) — derived, committed |
| `pasco refine` | `content/active.yaml` — the variant you picked |
| `pasco status --mark` | `content/deployments.yaml` — the deploy ledger (D18) |
| `pasco status --write-checklist` | `CHECKLIST.md` — AUTO-GENERATED view of the ledger |

Everything else only reads. `profiles/` is generated output and **is** committed:
it is the deploy artifact. Never hand-edit it — fix `content/` and rebuild.

## The three evidence concepts (do not mix them)

| Concept | Block | It is | Example |
|---|---|---|---|
| **Claim** | `projects[].evidence[]` | a textual assertion + source | "raised $2M" → TechCrunch link |
| **Credential** | `content/credentials.yaml` | a third-party attestation | AWS cert, degree, award, patent |
| **Artifact** | `content/artifacts.yaml` | a work or media item | portfolio, showreel, dataset, code |

`publications[]` and `press[]` keep their own blocks and **reference** registry
ids via `artifactRefs`; they are not registry kinds. (`press[]` is a **brand**
flavor block; this template ships `flavor: person`, so a write-up *about you* is
an artifact of `kind: document` or a claim. See
[docs/evidence-packs.md](docs/evidence-packs.md).)

A reference to an `id` that does not exist fails the load (`dangling cross-ref`,
exit 1) — it is not silently ignored.

### Visibility — the rule is stricter than the names suggest

`visibility: public | unlisted | private` (absent = `public`). Only `public`
counts as public. `unlisted` and `private` are treated the same by the gate:
neither can be referenced from public output, and neither is emitted in renders.
`pasco check` fails the build if public material references one.

### Media — one path to the public web

`media/` holds small, versionable binaries. A `path` locator is the source of
truth; the renderer bundles it into `profiles/<platform>/assets/` with a
`sha256` manifest, and the deployed output links a **deploy-relative**
`assets/<id>/<basename>`. Never hot-link a file from a private repository: for
the rest of the world it is a 404.

Limits and tradeoffs: [media/README.md](media/README.md),
[docs/power-user-symlinks.md](docs/power-user-symlinks.md).

## Repository map

```
profile-data-<username>/
├── content/              # YOUR data (YAML)
│   ├── credentials.yaml  # third-party attestations (optional, D17/§18)
│   ├── artifacts.yaml    # works and media (optional, D17/§18)
│   └── deployments.yaml  # deploy ledger (written only by pasco status --mark)
├── media/                # small versionable binaries (optional, §18.6)
├── docs/                 # evidence packs · symlink/stow tradeoffs · standards
├── profiles/             # generated deploy artifacts (committed, never hand-edited)
├── .github/              # CI, link/secret/example-data gates, issue templates
├── .pascorc              # CLI config: workspace, defaults, diff.tagPattern
├── CHECKLIST.md          # per-platform post-deploy verification
└── CHANGELOG.md          # every change: date + what to re-paste
```

## CI and automation

Five checks plus the build job. All actions are **pinned by full commit SHA**;
[Dependabot](.github/dependabot.yml) keeps the pins current.

| Workflow | Trigger | What it does |
|---|---|---|
| `checks.yml` → `yaml` | push to main + every PR | `content/*.yaml` parses |
| `checks.yml` → `links` | same | relative markdown links resolve, plus a self-test that the gate rejects a broken link |
| `checks.yml` → `example-data` | same | `content/` is still fictional, `media/` still empty, no local state tracked |
| `checks.yml` → `secrets` | same | `gitleaks` (pinned CLI + SHA-256) scans the full history |
| `checks.yml` → `evidence` | same | `pasco validate` + `pasco check` (the §18.8 gate) |
| `workflow-lint.yml` | workflows change | every workflow file parses — kept separate so it can cover `checks.yml` itself |
| `build.yml` | push to main touching `content/**`, `.pascorc`, the link script or itself | validate + check + build, then commits `profiles/` |

The `example-data` job runs **only in this template repository** — a fork
legitimately carries a real identity, so the guard skips there (running it in a
fork would fail on every PR).

The build job is the only one with `contents: write`. In **user workspaces** it
commits the generated output as `github-actions[bot]`; in **this template** it
refuses (the `is_template` check is fail-closed: a missing flag aborts instead of
pushing blind). Its push uses `GITHUB_TOKEN`, so it triggers no workflow — that is
why it runs the link gate itself, through the same
[`.github/scripts/check-links.sh`](.github/scripts/check-links.sh) used by `checks.yml`.

## Security and privacy

- **No real data in this repository.** `content/` is a fictional example and
  `media/` ships empty; CI fails here if that stops being true (the guard skips
  in forks, where real data is the point).
- **Never paste real profile data, tokens or private media into an issue or PR.**
  This repo is public; your workspace is not.
- **Security reports go through GitHub privately**, never a public issue: see
  [SECURITY.md](SECURITY.md).
- **Forking is your responsibility.** Create the fork private, keep the engine
  pinned, and review dependency updates before merging them.
- Local state that may contain machine paths (`.pasco/`) is gitignored.

## Contributing

Contributions are welcome when they help **every user of the family**, not one
person's data. Start with [CONTRIBUTING.md](CONTRIBUTING.md); the
[Code of Conduct](CODE_OF_CONDUCT.md) applies. Open an issue before a large
feature; bugs and proposals have issue templates.

## Releases

Versions mirror the engine pin: `MAJOR.MINOR` is the engine line, `PATCH` is this
scaffold's revision. `v0.3.0` is the first tagged release. Tagging, the re-sync
of a fork, and the list of files that must be bumped together are in
[CONTRIBUTING.md § Releases](CONTRIBUTING.md#releases).

## Troubleshooting

| Symptom | Cause / fix |
|---|---|
| `pasco: command not found` | Install it (`npm i -g @profile-as-code/cli@0.3.0`) or run `npx -y @profile-as-code/cli@0.3.0 <cmd>` |
| `validate` fails on `dangling cross-ref` | A `credentialId` / `artifactId` / `artifactRefs` points to an `id` that does not exist |
| `check` fails on private-in-public-output | A public claim references an `unlisted`/`private` entry — make it `public` or drop the reference |
| The build bot commits nothing | Confirm this is a user workspace (not the template), Actions is enabled, and the push touched one of the watched paths |
| A workflow dies in 0s (`startup_failure`) | A YAML error in that workflow. `workflow-lint.yml` exists for exactly this class and parses the files in CI |
| Generated README links 404 | `assets/` was not committed with the output, or the link is not deploy-relative |

## Roadmap

The scaffold follows the engine's milestones; the current line is engine `0.3.x`.
Priorities and open work live in [issues](https://github.com/ChristianLuciani/profile-data-template/issues)
and in the engine's roadmap. `pasco check` executes the registry and media rules
today; the remaining declarative catalog ships with engine M3/M4.

## License

[MIT](LICENSE). When you fork this template for your own workspace, replace the
`Copyright (c)` line in `LICENSE` with your name.

## Links

- Engine: https://github.com/ChristianLuciani/profile-as-code
- Engine spec: https://github.com/ChristianLuciani/profile-as-code/blob/main/docs/SPEC.md
- Schema: https://github.com/ChristianLuciani/profile-as-code/blob/main/schema/profile.schema.json
- Prior art: https://github.com/ChristianLuciani/profile-as-code/blob/main/docs/research/01-prior-art.md
- Media pipeline: https://github.com/ChristianLuciani/profile-as-code/blob/main/docs/media-pipeline.md

---

[Español](README.es.md)
