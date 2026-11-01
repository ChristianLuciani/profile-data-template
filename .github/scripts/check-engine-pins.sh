#!/usr/bin/env bash
#
# check-engine-pins.sh — one source for the engine pin.
#
# The pin lives in `.pascorc` → `engine` (the floor the CLI enforces from 0.3.7
# on) and in every place a workflow or local action names the CLI package.
# Nothing compared them, and the drift is measured: PR #25's premerge review
# found the pin-surface list missing `preview.yml` (round 1, F2) and the
# reconcile commit reintroduced two findings of the same class (round 2, F2/F3).
# A comment saying "keep them in sync" is prose; this script is the gate.
#
# The rule is a WHITELIST OF STRINGS, not a detector of install commands. Every
# occurrence of `@profile-as-code/cli` in a workflow or local action must be
# followed immediately by `@<the exact .pascorc engine>`. There is no list of
# commands to enumerate, so no form can slip through: `npm i`, `npm exec`,
# `npx`, `pnpm`, `yarn`, a spec held in an `env:`/`matrix` variable, a quoted
# `#` mid-line, a backslash continuation — if the package is named, its version
# is the floor or the gate is red. An earlier command-allow-list version of this
# script was bypassed three review rounds in a row, one new command form per
# round; the string rule closes that whole class by construction.
#
# Also enforced:
#   - a file that runs `pasco` must name the pinned package (otherwise the pin is
#     silently unchecked there);
#   - full-line comments are ignored (a note is not code) — inline text is not;
#   - at least one file must name the pin, or there is nothing to compare.
#
# Usage: check-engine-pins.sh [-w <workspace>]   (default: git root of cwd)
# Exit: 0 every mention is the exact pin · 1 a mention, a version or the floor is
#       wrong · 2 usage error or unreadable .pascorc
set -euo pipefail

root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
while [ $# -gt 0 ]; do case "$1" in
  -w)
    [ $# -ge 2 ] || { echo "usage: $0 [-w <workspace>]" >&2; exit 2; }
    root="$2"; shift 2 ;;
  -h|--help)
    cat <<'USAGE'
usage: check-engine-pins.sh [-w <workspace>]

Requires every mention of @profile-as-code/cli in .github/workflows/ and
.github/actions/ to be exactly @<MAJOR.MINOR.PATCH from .pascorc -> engine.
Exit: 0 all mentions pinned · 1 wrong/missing/inexact · 2 usage or bad config
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
FLOOR = "@" + want
VERSIONISH = re.compile(r"[0-9A-Za-z.+-]")
RUNS = re.compile(r"(^|\s|`|\"|')pasco\b")


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


files = collect()
if not files:
    print("::error::no workflow or action files under .github/", file=sys.stderr)
    sys.exit(1)

rc = 0
pinned = 0
for path in files:
    rel = os.path.relpath(path, root)
    with open(path, encoding="utf-8", errors="replace") as fh:
        text = fh.read()
    # only full-line comments are ignored: inline text is code, and a quoted '#'
    # must not be able to hide a mention
    code = [line for line in text.splitlines()
            if not line.lstrip().startswith("#")]

    mentions = 0
    ok = True
    for line in code:
        for m in re.finditer(re.escape(PKG), line):
            mentions += 1
            tail = line[m.end():]
            if tail.startswith(FLOOR) and not (
                    len(tail) > len(FLOOR) and VERSIONISH.match(tail[len(FLOOR)])):
                continue
            shown = (PKG + tail).strip()
            if not tail.startswith("@"):
                print(f"::error file={rel}::names {PKG} with no version "
                      f"({shown[:60]}) — .pascorc declares engine {want}")
            elif re.match(r"^[0-9]+(\.[0-9]+){2}[0-9A-Za-z.+-]", tail[1:]):
                print(f"::error file={rel}::{shown[:60]} is not an exact "
                      f"MAJOR.MINOR.PATCH pin — .pascorc declares engine {want}")
            else:
                print(f"::error file={rel}::{shown[:60]} does not match "
                      f".pascorc engine {want}")
            ok = rc = 1
    if mentions and ok:
        pinned += 1
    if mentions == 0 and RUNS.search("\n".join(code)):
        print(f"::error file={rel}::runs pasco but never names {PKG}@{want} — "
              f"the pin would go unchecked here")
        rc = 1

if pinned == 0:
    print(f"::error::no workflow or action names {PKG}@{want} — nothing to "
          f"compare against .pascorc", file=sys.stderr)
    sys.exit(1)
if rc == 0:
    print(f"engine pins agree: {want} ({pinned} file(s) name the pin)")
sys.exit(rc)
PY
