#!/usr/bin/env bash
# Template guard — this repository is a *template*, not anyone's data.
#
# A forker copies `content/` verbatim. If a real person's facts, email, or media
# ever land here, every fork inherits them. This gate fails the build when the
# example stops being fictional, so the mistake is caught in CI instead of in a
# public fork.
#
# Checks (all offline, no engine):
#   1. content/identity.yaml still declares the documented example persona.
#   2. Every email in content/ uses an example.* domain.
#   3. No absolute home-directory paths in content/ (they leak a machine layout).
#   4. No mailto:/javascript:/data: schemes in content/ (schema also rejects them).
#   5. media/ ships empty — only .gitkeep and README.md.
#   6. Local state (.pasco/, .env*) is not tracked by git.
#
# Exit 1 on any finding, with a GitHub annotation per finding.
set -uo pipefail

cd "$(dirname "$0")/../.." || exit 2

FAIL=0
fail() {
  printf '::error file=%s::%s\n' "${1:-unknown}" "${2:-finding}"
  FAIL=1
}

EXPECTED_NAME="Alex Rivera"

# 1) The example persona is load-bearing: docs, screenshots and the engine's own
#    examples all say "Alex Rivera". Changing it is fine — update this constant in
#    the same PR, so the change is deliberate and reviewed.
name="$(sed -n 's/^name:[[:space:]]*//p' content/identity.yaml 2>/dev/null | head -1 | sed 's/[[:space:]]*$//')"
if [ "$name" != "$EXPECTED_NAME" ]; then
  fail "content/identity.yaml" "example persona changed (expected '${EXPECTED_NAME}', found '${name:-<none>}') — this template must not ship a real identity"
fi

# 2) Emails must be example domains.
while IFS= read -r hit; do
  [ -n "$hit" ] || continue
  file="${hit%%:*}"
  rest="${hit#*:}"
  line="${rest%%:*}"
  email="${rest#*:}"
  case "$email" in
    *@example.com | *@example.org | *@example.net) ;;
    *) fail "$file:$line" "non-example email '$email' — template content must stay fictional" ;;
  esac
done < <(grep -rInoE '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}' content 2>/dev/null || true)

# 3) Absolute home paths in content/ leak the author's machine.
while IFS= read -r hit; do
  [ -n "$hit" ] || continue
  fail "${hit%%:*}" "absolute home path in content/ — remove it (${hit#*:})"
done < <(grep -rInE '(/Users/[^/[:space:]]+|/home/[^/[:space:]]+)' content 2>/dev/null || true)

# 4) Non-http(s) schemes in data (comment lines that *document* the rule are fine).
while IFS= read -r hit; do
  [ -n "$hit" ] || continue
  rest="${hit#*:}"
  payload="${rest#*:}"
  trimmed="${payload#"${payload%%[![:space:]]*}"}"
  case "$trimmed" in \#*) continue ;; esac
  fail "${hit%%:*}" "non-http(s) scheme in content/ (${payload})"
done < <(grep -rInE '(mailto:|javascript:|data:text/html)' content 2>/dev/null || true)

# 5) media/ ships empty: only placeholders.
while IFS= read -r f; do
  [ -n "$f" ] || continue
  fail "$f" "media/ must ship empty in the template — a forker should never inherit binaries"
done < <(find media -type f ! -name '.gitkeep' ! -name 'README.md' 2>/dev/null || true)

# 6) Local state that can hold paths or secrets must never be tracked.
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    fail "$f" "local state must be gitignored, not committed"
  done < <(git ls-files | grep -E '(^|/)\.pasco/|(^|/)\.env(\.|$)' || true)
fi

if [ "$FAIL" -ne 0 ]; then
  echo "example-data guard: FAILED — this repository is a template; content/ must stay fictional and media/ empty." >&2
  exit 1
fi

echo "example-data guard: OK — content/ is fictional and media/ ships empty"
