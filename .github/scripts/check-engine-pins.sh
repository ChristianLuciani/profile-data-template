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
# Rules, per workflow file:
#   - every install of `@profile-as-code/cli` must name a full MAJOR.MINOR.PATCH
#     pin (no range, dist-tag, `v` prefix, suffix or missing version), and it
#     must equal `.pascorc` → `engine`;
#   - a workflow that runs `pasco` but installs no pinned CLI is an error: the
#     pin would otherwise be silently unchecked there;
#   - comment lines and trailing comments are ignored (a note is not an install);
#   - at least one workflow must carry a pin, or there is nothing to compare.
#
# Usage: check-engine-pins.sh [-w <workspace>]   (default: git root of cwd)
# Exit: 0 every pin agrees · 1 a pin disagrees / is missing / is not a full pin
#       · 2 usage error, unreadable .pascorc, or no workflow files
set -euo pipefail

root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
while [ $# -gt 0 ]; do case "$1" in
  -w)
    [ $# -ge 2 ] || { echo "usage: $0 [-w <workspace>]" >&2; exit 2; }
    root="$2"; shift 2 ;;
  -h|--help) sed -n '2,28p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
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

files = sorted(glob.glob(os.path.join(root, ".github", "workflows", "*.yml"))) + \
        sorted(glob.glob(os.path.join(root, ".github", "workflows", "*.yaml")))
if not files:
    print("::error::no workflow files under .github/workflows", file=sys.stderr)
    sys.exit(1)

rc = 0
pinned = 0
for path in files:
    rel = os.path.relpath(path, root)
    with open(path, encoding="utf-8", errors="replace") as fh:
        text = fh.read()
    # a trailing comment is not an install; a full-line comment is not code
    lines = [line.split("#", 1)[0] for line in text.splitlines()]
    code = "\n".join(lines)

    pins = []
    for line in lines:
        if not INSTALL.search(line):
            continue
        for m in re.finditer(re.escape(PKG) + r"(@[^\s`'\"),;]*)", line):
            pins.append(m.group(1)[1:] if m.group(1) else "")

    ok = True
    for got in pins:
        if not got:
            print(f"::error file={rel}::installs {PKG} with no version (latest) "
                  f"— .pascorc declares engine {want}")
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
    if RUNS.search(code) and not pins:
        print(f"::error file={rel}::runs pasco but installs no {PKG}@X.Y.Z — "
              f"the pin would go unchecked here")
        rc = 1

if pinned == 0:
    print(f"::error::no workflow installs {PKG} — nothing to compare against "
          f".pascorc", file=sys.stderr)
    sys.exit(1)
if rc == 0:
    print(f"engine pins agree: {want} ({pinned} workflow(s) install the CLI)")
sys.exit(rc)
PY
