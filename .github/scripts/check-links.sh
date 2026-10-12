#!/usr/bin/env bash
# check-links.sh — fail if a relative markdown link does not resolve.
#
# One copy, two callers (a second copy would drift):
#   - .github/workflows/checks.yml  job `links`  → every tracked `.md`
#   - .github/workflows/build.yml   before the bot commits generated `profiles/`
#     (that push carries GITHUB_TOKEN, which triggers no workflow, so
#      checks.yml never sees the commit — see CONTRIBUTING.md § CI)
#
# Usage: check-links.sh [file ...]
#        no arguments → every markdown file tracked by git
set -uo pipefail

if [ "$#" -gt 0 ]; then
  candidates="$(printf '%s\n' "$@")"
else
  # A failed enumeration must NOT read as "no broken links": reporting success
  # after checking zero files is the "gate that never fires" failure this repo
  # has already paid for twice (see the NOTE in checks.yml). Zero *files* is a
  # legitimate result; a broken `git ls-files` is not.
  if ! candidates="$(git ls-files '*.md')"; then
    echo "::error::git ls-files failed — cannot enumerate markdown files; refusing to report success"
    exit 1
  fi
fi

broken_marker="$(mktemp)"
trap 'rm -f "$broken_marker"' EXIT

checked=0
while IFS= read -r f; do
  [ -n "$f" ] || continue
  [ -e "$f" ] || continue
  checked=$((checked + 1))
  # The trailing `|| true` is defensive, not load-bearing: this script runs as a
  # child shell, so it does not inherit `-e` from the caller — and no caller sets
  # it. It is kept because with errexit ON, a file with NO relative links makes
  # the first grep exit 1 and would abort the script early, silently skipping the
  # remaining files (lessons 19/34: a gate that fires wrongly is as bad as one
  # that never fires). A link-less file is valid; a link to nowhere is not.
  # Strip inline code spans BEFORE looking for links: a link shown inside
  # backticks renders as text, not as a link, so scanning it only yields false
  # BROKEN reports — which is how this repo's own CHANGELOG tripped this gate the
  # moment it documented the regex's edge cases. A gate that fires wrongly is as
  # bad as one that never fires.
  # Residual: fenced code blocks and spans split across lines are still scanned.
  sed -E 's/`[^`]*`//g' "$f" \
    | grep -oE '\]\([^)#][^)]*\)' \
    | sed -E 's/^\]\(//; s/\)$//; s/[[:space:]]+"[^"]*"$//; s/^<//; s/>$//; s/#.*$//' \
    | grep -vE '^(https?:|mailto:)' \
    | while IFS= read -r link; do
        [ -z "$link" ] && continue
        target="$(dirname "$f")/$link"
        if [ ! -e "$target" ]; then
          echo "BROKEN  $f  ->  $link"
          echo broken >> "$broken_marker"
        fi
      done \
    || true
done <<< "$candidates"

if [ -s "$broken_marker" ]; then
  echo "::error::broken relative links found"
  exit 1
fi
echo "relative markdown links resolve (${checked} file(s) checked)"
