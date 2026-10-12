# Symlinks & stow — a local convenience, never the mechanism

You have a big media folder somewhere on your disk (`~/Pictures/portfolio`,
`/Volumes/Archive/reels`). You want the registry to point at it without copying
gigabytes into git. So you symlink it into `media/`:

```bash
ln -s ~/Pictures/portfolio media/portfolio
```

This works on your machine. It is also the single most common way people break
their workspace for everyone else — including their own future self on a new
laptop.

## Why it breaks: git stores the link, not the file

**Git commits a symlink as its target path, as text.** Not the bytes. Not a
copy. Just the string `~/Pictures/portfolio` (or worse, an absolute
`/Users/you/Pictures/portfolio`).

The consequences follow directly:

| Situation | What happens |
|---|---|
| Fresh clone on another machine | The link points at a path that doesn't exist. Broken. |
| CI (GitHub Actions) | Same. `~/Pictures/...` was never on the runner. |
| You reinstall / rename your home dir | Broken, and the fix is now in git history. |
| You move the folder | Broken. The link still has the old text. |
| Teammate clones your workspace | Broken, and confusing. |

A symlink is a **promise about your filesystem**, and git can only record the
promise, not keep it. `~` is not even expanded by git — it is literal text that
only a shell understands.

## What the engine does about it

`pasco check` warns rather than fails:

```
media-symlink-external — a workspace locator resolves through a symlink
                         escaping the workspace, with no declared checksum
```

It is a warning because stowing genuinely is useful locally, and the engine
refuses to make your machine's layout a hard error. But a warning is not a
guarantee — it tells you the render is machine-dependent.

The escape hatch: **declare a `checksum` on the artifact.** Then the promise is
verifiable wherever the bytes actually live:

```yaml
  - id: reel-archive
    kind: showreel
    title: "Archive reel"
    locator: { path: "media/archive/reel.mp4" }
    checksum: "sha256:0000…"   # the promise is now checkable
    visibility: public
```

With a checksum, a mismatch is an error instead of silence. Without one, nobody
— not you, not CI — can tell whether the bytes changed underneath.

## Do this instead

Pick per case; both are first-class and neither uses symlinks.

**1. Small files → actually put them in `media/`.**

A certificate scan, five portfolio stills, a press PDF. These belong in git.
They get history, backup, and review like the rest of your data. This is what
the `media/` scaffold is for.

**2. Big/external files → `PASCO_EVIDENCE_ROOT`.**

```bash
export PASCO_EVIDENCE_ROOT="$HOME/evidence"
```

Any `path` that isn't `media/…` resolves under that root:

```yaml
  - id: reel-2025
    kind: showreel
    title: "Reel 2025"
    locator: { path: "reels/2025.mp4" }   # → $HOME/evidence/reels/2025.mp4
    visibility: public
```

This is the **supported** external mechanism, and it has real advantages over a
symlink:

- **Explicit.** You declare the root; it isn't inferred from link text.
- **Per-machine and uncommitted** (env var, or `evidence_root` in the
  gitignored `.pasco/local.toml`) — so a fresh clone is never broken, it just
  can't see the asset yet.
- **Honest in CI.** A runner without the root warns
  (`media-external-missing`) and renders without the asset. It does not fail,
  and it does not silently render a broken link.
- **Containment-checked.** A resolved path that escapes the root is an error
  (`media-path-unsafe`), not a surprise.

**3. Already hosted somewhere → `url` locator.**

Vimeo, YouTube, Zenodo, S3, your own site. No copy, no root, no symlink, and you
get a live-link check:

```yaml
    locator: { url: "https://vimeo.com/000000" }
```

For video this is almost always the right answer.

## If you still want to stow locally

"Stow" (GNU Stow, or a manual symlink) is a legitimate power-user move: it lets
one directory serve several workspaces. Used knowingly, fine. Keep it inside
these bounds:

1. **Relative targets only.** `media/portfolio → ../../shared/portfolio`
   survives more machines than `~/Pictures/portfolio`. Absolute paths
   (`/Users/you/...`) are the worst case: they encode your username in git
   forever.
2. **Never the canonical mechanism.** The registry's portable options are
   `media/` (versioned), `PASCO_EVIDENCE_ROOT` (declared external) and `url`
   (hosted). A symlink is a local shortcut layered on top — the workspace must
   still make sense without it.
3. **Declare `checksum` for anything that matters.** It converts "trust my
   disk layout" into a verifiable claim.
4. **Expect the warning.** `media-symlink-external` on every `pasco check` is
   the engine telling you the truth. Don't silence it by removing the evidence —
   fix the transport.

## The one-line version

Git versions the link text, not the bytes: symlinks are a local convenience,
never the mechanism. Small files → `media/`. Big files → `PASCO_EVIDENCE_ROOT`
or a `url` locator. ([OFICIAL] SPEC §18.7, profile-as-code — D14 applied to
media.)
