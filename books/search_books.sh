#!/usr/bin/env bash
set -euo pipefail
ROOT="${BOOK_MANAGER_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
term="${1:-}"
[[ -n "$term" ]] || IFS= read -r term || true
"$ROOT/data/book_database.sh" search "$term"
