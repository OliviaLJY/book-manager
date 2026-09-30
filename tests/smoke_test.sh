#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export BOOK_MANAGER_ROOT="$ROOT"

tmp_db="$(mktemp "${TMPDIR:-/tmp}/books-backup.XXXXXX")"
cp "$ROOT/data/books.csv" "$tmp_db"
trap 'cp "$tmp_db" "$ROOT/data/books.csv"; rm -f "$tmp_db"' EXIT
printf 'title,author,genre,year,status,rating,link\n' > "$ROOT/data/books.csv"

"$ROOT/data/book_database.sh" add "Dune" "Frank Herbert" "Science Fiction" "1965" "finished" "5" ""
"$ROOT/data/book_database.sh" exists "Dune" "Frank Herbert"
[[ "$("$ROOT/books/search_books.sh" dune | cut -f1)" == "Dune" ]]
[[ "$(printf 'Dune | Frank Herbert\n' | "$ROOT/books/fetch_book_metadata.sh" | cut -d'|' -f3)" == "Science Fiction" ]]
refined="$(printf '%s\n' 'Dune|Frank Herbert|Science Fiction|duplicate' 'Kindred|Octavia E. Butler|Science Fiction|new' 'Kindred|Octavia E. Butler|Science Fiction|duplicate candidate' | "$ROOT/recommendations/refine_recommendations.sh")"
[[ "$(printf '%s\n' "$refined" | wc -l | tr -d ' ')" == 1 ]]
[[ "$refined" == Kindred\|* ]]
echo "Smoke test passed."
