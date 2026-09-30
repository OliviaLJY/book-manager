#!/usr/bin/env bash
set -euo pipefail
ROOT="${BOOK_MANAGER_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

# Preserve first occurrence, reject malformed/already-saved books, and cap the shortlist.
awk -F'|' 'NF >= 4 && !seen[tolower($1) "|" tolower($2)]++ { print }' |
while IFS='|' read -r title author genre reason; do
  if ! "$ROOT/data/book_database.sh" exists "$title" "$author"; then
    printf '%s|%s|%s|%s\n' "$title" "$author" "$genre" "$reason"
  fi
done | awk 'NR <= 5'
