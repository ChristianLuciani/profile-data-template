#!/usr/bin/env bash
#
# check-engine-pins.sh — one source for the engine pin.
#
# The pin lives in two places: `.pascorc` → `engine` (the floor the CLI enforces
# from 0.3.7 on) and the install command of every workflow that runs `pasco`.
# Nothing compared them, and the drift is measured: PR #25's premerge review
# found the pin-surface list missing `preview.yml` (round 1, F2) and the
# reconcile commit reintroduced two findings of the same class (round 2, F2/F3).
# A comment saying "keep them in sync" is prose; this script is the gate.
#
# Rules, over every workflow and every local composite action:
#   - EVERY occurrence of `@profile-as-code/cli` on an install line must be
#     followed by `@<exact .pascorc engine>` — so a bare package name (latest),
#     a range, a dist-tag, a `v` prefix, a suffix or any other version fails.
#     Counted per occurrence, not per file: one good pin cannot immunize a
#     second, drifting install in the same file;
#   - backslash line continuations are joined first, so a pin on the next line
#     of an install command is still seen;
#   - a file that runs `pasco` but carries no pin is an error (the pin would be
#     silently unchecked there);
#   - comment lines and trailing comments are ignored (a note is not an install);
#   - at least one pin must exist overall, or there is nothing to compare.
#
# Usage: check-engine-pins.sh [-w <workspace>]   (default: git root of cwd)
# Exit: 0 every pin agrees · 1 a pin disagrees / is missing / is not a full pin
#       · 2 usage error or unreadable .pascorc
set -euo pipefail

root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
while [ $# -gt 0 ]; do case "$1" in
  -w)
    [ $# -ge 2 ] || { echo "usage: $0 [-w <workspace>]" >&2; exit 2; }
    root="$2"; shift 2 ;;
  -h|--help)
    cat <<'USAGE'
usage: check-engine-pins.sh [-w <workspace>]

Requires every install of @profile-as-code/cli in .github/workflows/ and
.github/actions/ to name exactly the MAJOR.MINOR.PATCH in .pascorc -> engine.
Exit: 0 agree · 1 mismatch / missing / not a full pin · 2 usage or bad config
USAGE
    exit 0 ;;
  *) echo "usage: $0 [-w <workspace>]" >&2; exit 2 ;;
esac; done

cfg="$root/.pascorc"
[ -f "$cfg" ] || { echo "::error::$cfg not found"; exit 2; }
want="$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1])).get("engine",""))' "$cfg" 2>/dev/null)" \
  || { echo "::error file=.pascorc::not readable as JSON"; exit 2; }
[ -n "$want" ] || { echo "::error file=.pascorc::no \"engine\" key — the workspace declares no floor"; exit 1; }
printf '%s' "$want" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+$' \
  || { echo "::error file=.pascorc::engine \"$want\" is not MAJOR.MINOR.PATCH"; exit 1; }

python3 - "$root" "$want" <<'PY'
import glob
import os
import re
import sys

root, want = sys.argv[1], sys.argv[2]
PKG = "@profile-as-code/cli"
FULL = re.compile(r"^[0-9]+\.[0-9]+\.[0-9]+$")
# an install line calls a package manager and is not a comment
INSTALL = re.compile(r"(^|\s)(npm\s+(i|install|ci)\b|npx\b|pnpm\b|yarn\b)")
RUNS = re.compile(r"(^|\s|`|\"|')pasco\b")
TOKEN = re.compile(r"@([^\s`'\"),;]*)")


def collect():
    found = []
    for base in (os.path.join(root, ".github", "workflows"),
                 os.path.join(root, ".github", "actions")):
        if not os.path.isdir(base):
            continue
        for pattern in ("*.yml", "*.yaml", "**/*.yml", "**/*.yaml"):
            found.extend(glob.glob(os.path.join(base, pattern), recursive=True))
    out, seen = [], set()
    for path in sorted(found):
        if path not in seen:
            seen.add(path)
            out.append(path)
    return out


def logical_lines(text):
    """Join shell backslash continuations; drop comments (a note is not code)."""
    out, buf = [], ""
    for raw in text.splitlines():
        code = raw.split("#", 1)[0]
        if buf:
            code = buf + " " + code.strip()
        if code.rstrip().endswith("\\"):
            buf = code.rstrip()[:-1]
            continue
        buf = ""
        out.append(code)
    if buf:
        out.append(buf)
    return out


files = collect()
if not files:
    print("::error::no workflow or action files under .github/", file=sys.stderr)
    sys.exit(1)

rc = 0
pinned = 0
for path in files:
    rel = os.path.relpath(path, root)
    with open(path, encoding="utf-8", errors="replace") as fh:
        lines = logical_lines(fh.read())
    code = "\n".join(lines)

    pins = 0
    ok = True
    for line in lines:
        if not INSTALL.search(line):
            continue
        for m in re.finditer(re.escape(PKG), line):
            pins += 1
            tm = TOKEN.match(line, m.end())
            got = tm.group(1) if tm else ""
            if not got:
                print(f"::error file={rel}::installs {PKG} with no version "
                      f"(latest) — .pascorc declares engine {want}")
                ok = rc = 1
            elif not FULL.match(got):
                print(f"::error file={rel}::installs {PKG}@{got} — not a full "
                      f"MAJOR.MINOR.PATCH pin (range, dist-tag, prefix or suffix)")
                ok = rc = 1
            elif got != want:
                print(f"::error file={rel}::installs {PKG}@{got} but .pascorc "
                      f"declares engine {want}")
                ok = rc = 1
    if pins and ok:
        pinned += 1
    if RUNS.search(code) and pins == 0:
        print(f"::error file={rel}::runs pasco but installs no {PKG}@X.Y.Z — "
              f"the pin would go unchecked here")
        rc = 1

if pinned == 0:
    print(f"::error::no workflow or action installs {PKG} — nothing to compare "
          f"against .pascorc", file=sys.stderr)
    sys.exit(1)
if rc == 0:
    print(f"engine pins agree: {want} ({pinned} file(s) install the CLI)")
sys.exit(rc)
PY
