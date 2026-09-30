#!/usr/bin/env bash
# The only program that knows how books.csv is stored.
set -euo pipefail

ROOT="${BOOK_MANAGER_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
DB="$ROOT/data/books.csv"
HEADER='title,author,genre,year,status,rating,link'

clean_field() {
  # This small CSV deliberately forbids embedded commas and newlines.
  printf '%s' "$1" | tr ',\r\n' '   ' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
}

lower() { printf '%s' "$1" | tr '[:upper:]' '[:lower:]'; }

init_db() {
  [[ -f "$DB" ]] || printf '%s\n' "$HEADER" > "$DB"
}

list_books() {
  init_db
  awk -F, 'NR > 1 { printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\n", $1,$2,$3,$4,$5,$6,$7 }' "$DB"
}

search_books() {
  local term
  term="$(lower "$1")"
  init_db
  awk -F, -v q="$term" 'BEGIN { IGNORECASE=1 } NR > 1 && index(tolower($0), q) {
    printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\n", $1,$2,$3,$4,$5,$6,$7
  }' "$DB"
}

exists_book() {
  local title author
  title="$(lower "$1")"; author="$(lower "${2:-}")"
  init_db
  awk -F, -v t="$title" -v a="$author" 'NR > 1 && tolower($1)==t && (a=="" || tolower($2)==a) { found=1 } END { exit !found }' "$DB"
}

add_book() {
  [[ $# -eq 7 ]] || { echo "add requires 7 fields" >&2; exit 2; }
  local title author genre year status rating link
  title="$(clean_field "$1")"; author="$(clean_field "$2")"
  genre="$(clean_field "$3")"; year="$(clean_field "$4")"
  status="$(clean_field "$5")"; rating="$(clean_field "$6")"
  link="$(clean_field "$7")"
  [[ -n "$title" && -n "$author" ]] || { echo "Title and author are required." >&2; exit 2; }
  case "$status" in want-to-read|reading|finished|owned) ;; *) echo "Invalid status: $status" >&2; exit 2;; esac
  if exists_book "$title" "$author"; then
    echo "That book is already in your library." >&2; exit 1
  fi
  printf '%s,%s,%s,%s,%s,%s,%s\n' "$title" "$author" "$genre" "$year" "$status" "$rating" "$link" >> "$DB"
}

update_field() {
  local title column="$2" value
  title="$(lower "$1")"
  value="$(clean_field "$3")"
  local tmp
  tmp="$(mktemp "${TMPDIR:-/tmp}/books.XXXXXX")"
  awk -F, -v OFS=, -v t="$title" -v c="$column" -v v="$value" '
    NR==1 { print; next }
    tolower($1)==t { $c=v; changed=1 }
    { print }
    END { if (!changed) exit 3 }
  ' "$DB" > "$tmp" || { rm -f "$tmp"; echo "Book not found: $1" >&2; exit 1; }
  mv "$tmp" "$DB"
}

genres() { list_books | awk -F '\t' '$3!="" { print $3 }' | sort | uniq -c | sort -rn; }
finished() { list_books | awk -F '\t' '$5=="finished" { print }'; }

command="${1:-help}"; shift || true
case "$command" in
  init) init_db ;;
  add) init_db; add_book "$@" ;;
  list) list_books ;;
  search) search_books "${1:-}" ;;
  exists) exists_book "${1:-}" "${2:-}" ;;
  update-status) init_db; update_field "$1" 5 "$2" ;;
  update-rating) init_db; [[ "$2" =~ ^([1-5]|)$ ]] || { echo "Rating must be 1-5 or blank." >&2; exit 2; }; update_field "$1" 6 "$2" ;;
  genres) genres ;;
  finished) finished ;;
  *) echo "Usage: $0 {init|add|list|search|exists|update-status|update-rating|genres|finished}" >&2; exit 2 ;;
esac
