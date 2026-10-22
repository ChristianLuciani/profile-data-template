# media/ — the bytes behind your artifacts

This folder holds the **actual files** your evidence registry points at: certificate
scans, portfolio shots, press clippings, datasets. The registry
(`content/artifacts.yaml`) declares *pointers*; this is where the bytes live.

It ships **empty on purpose** — the subfolders below are a convention, not a
requirement. Delete what you don't use.

```
media/
├── certificates/   # scans of credentials, diplomas, awards, patents
├── photos/         # portfolio shots, headshots, gallery images
└── press/          # clippings, PDFs of articles about you
```

## What belongs here

**Small files that are worth versioning** — a certificate scan, a handful of
portfolio stills, a press clipping. These travel with the repo, so they get the
same history, review and backup as your facts.

**What does NOT belong here:** showreels, raw video, PSDs, multi-GB datasets.
Those are large, mutable, and change constantly. Host them elsewhere (Vimeo,
YouTube, Zenodo, S3…) and use a `url` locator instead — the registry supports
both, and `url` locators get a live-link check.

## Size limits

| Threshold | What happens |
|---|---|
| **> 50 MB** | `pasco check` warns (`media-oversize`) — reconsider the transport |
| **100 MB** | GitHub **hard-blocks** the file. Not a warning — a wall. |

Sources: 50 MB is the engine's advisory threshold ([OFICIAL] SPEC §18.6,
profile-as-code); 100 MB is GitHub's per-file limit ([OFICIAL] [WEB:
docs.github.com, verified 2026-10-12]).

If you truly must version a large file, **git-lfs** is the operator's call — the
engine never mutates your repo:

```bash
git lfs install
# One pattern per extension: git-lfs globs do not expand braces.
git lfs track "media/**/*.mp4" "media/**/*.zip" "media/**/*.psd"
git add .gitattributes
```

CI needs `lfs: true` on checkout, otherwise `pasco check` checksums the *pointer
file* instead of the content. A declared `checksum` makes that mistake visible.

> This **template** repository ships `media/` empty on purpose, and
> `.github/scripts/check-example-data.sh` fails the build if a binary lands here.
> Your fork is where the bytes belong (or an external host, via a `url` locator).

## The no-hot-link rule (important)

**While your workspace is private, never hot-link `media/` files from a public
surface.** A raw URL to a file in a private repo leaks nothing publicly — it
just 404s for everyone, and it may expose your repo's existence and structure.

Media reaches the public web through **one** path only:

```
media/  ──▶  collectMedia (sha256 + bytes)  ──▶  profiles/<platform>/assets/  ──▶  deploy
```

- `pasco build <platform>` copies the referenced files into
  `profiles/<platform>/assets/<id>/<basename>` and writes
  `assets/manifest.json` (the checksum record).
- The deployed README links `assets/<id>/<basename>` — a **deploy-relative**
  path that resolves only after the output is committed to the public surface.
- That is not a private-repo URL: it is a public file in a public repo.

So: `path` locators are for your private workspace and the bundler. Never paste
a `raw.githubusercontent.com` link to a private-repo file into a public profile.

## Big or external collections — `PASCO_EVIDENCE_ROOT`

Don't want gigabytes in git? Point `path` locators at files **outside** the
workspace and set one env var:

```bash
export PASCO_EVIDENCE_ROOT="$HOME/evidence"
```

A `path` that is not `media/…` resolves under that root. Tradeoffs, stated
plainly:

- **`PASCO_EVIDENCE_ROOT` is per-machine state — never committed.** It is an env
  var, or `evidence_root` in the gitignored `.pasco/local.toml`. Keep it out of
  the repo (same rule as secrets).
- **CI is degraded without the files.** A runner with no evidence root simply
  skips external assets (`media-external-missing`, a warn). The render stays
  valid — it just renders without that asset. Warnings, not failures.
- **Declare a `checksum`** (`sha256:<64 hex>`) if the file must be verifiable
  wherever it lives. With a checksum the promise is checkable; without one,
  nobody can tell the bytes changed.

Rules of thumb: **in `media/`** → versioned, portable, works in CI.
**External** → flexible, big, needs setup on every machine.

## Locator quick reference

| You want | Locator | Where it works |
|---|---|---|
| A small file that travels with the repo | `{ path: media/certificates/x.pdf }` | Everywhere |
| A big file on your own disk | `{ path: /abs/… }` + `PASCO_EVIDENCE_ROOT` | Your machine; warns in CI |
| Something already hosted (Vimeo, Zenodo) | `{ url: https://… }` | Everywhere + live-link checked |

Exactly **one** of `url` or `path` per locator. Both is a schema error.

See `docs/evidence-packs.md` for per-domain checklists, and the engine's
`docs/media-pipeline.md` for the full transport contract.
