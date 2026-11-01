#!/usr/bin/env bash
#
# check-engine-pins.sh — one source for the engine pin.
#
# The pin lives in two places: `.pascorc` → `engine` (the floor the CLI enforces
# from 0.3.7 on) and the install line of every workflow that installs the CLI.
# Nothing compared them, and the drift is measured: PR #25's premerge review
# found the pin-surface list missing `preview.yml` (round 1, F2) and the
# reconcile commit reintroduced two findings of the same class (round 2, F2/F3).
# A comment saying "keep them in sync" is prose; this script is the gate.
#
# Usage: check-engine-pins.sh [-w <workspace>]   (default: git root of cwd)
# Exit: 0 every pin agrees with the floor · 1 a pin disagrees or none is found
#       · 2 usage error or unreadable .pascorc
#
# Scans .github/workflows/*.{yml,yaml} for `@profile-as-code/cli@X.Y.Z` and
# requires every distinct value to equal `.pascorc` → `engine`. Documentation
# mentions (README badges) are deliberately out of scope: they do not install.
set -euo pipefail

root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
while [ $# -gt 0 ]; do case "$1" in
  -w) root="$2"; shift 2 ;;
  -h|--help) sed -n '2,20p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
  *) echo "usage: $0 [-w <workspace>]" >&2; exit 2 ;;
esac; done

cfg="$root/.pascorc"
[ -f "$cfg" ] || { echo "::error::$cfg not found"; exit 2; }
want="$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1])).get("engine",""))' "$cfg")" \
  || { echo "::error file=.pascorc::not readable as JSON"; exit 2; }
[ -n "$want" ] || { echo "::error file=.pascorc::no \"engine\" key — the workspace declares no floor"; exit 1; }

rc=0
found=0
for f in "$root"/.github/workflows/*.yml "$root"/.github/workflows/*.yaml; do
  [ -f "$f" ] || continue
  rel="${f#"$root"/}"
  # distinct pins in the file: a file may install more than one, and all must agree
  pins="$(grep -oE '@profile-as-code/cli@[0-9]+\.[0-9]+\.[0-9]+' "$f" 2>/dev/null | sed 's/.*@//' | sort -u || true)"
  [ -n "$pins" ] || continue
  found=$((found + 1))
  for got in $pins; do
    if [ "$got" != "$want" ]; then
      echo "::error file=$rel::installs @profile-as-code/cli@$got but .pascorc declares engine $want"
      rc=1
    fi
  done
done

if [ "$found" -eq 0 ]; then
  echo "::error::no workflow installs @profile-as-code/cli — nothing to compare against .pascorc"
  exit 1
fi
[ "$rc" -eq 0 ] && printf 'engine pins agree: %s (%s workflow(s) install the CLI)\n' "$want" "$found"
exit "$rc"
