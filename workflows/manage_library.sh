#!/usr/bin/env bash
set -euo pipefail
ROOT="${BOOK_MANAGER_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

ask() { local prompt="$1"; if command -v gum >/dev/null 2>&1; then gum input --prompt "$prompt: "; else read -r -p "$prompt: " REPLY; printf '%s' "$REPLY"; fi; }
choose() { local header="$1"; shift; if command -v gum >/dev/null 2>&1; then printf '%s\n' "$@" | gum choose --header "$header"; else select choice in "$@"; do printf '%s' "$choice"; break; done; fi; }

case "${1:-}" in
  browse) "$ROOT/data/book_database.sh" list | "$ROOT/ui/library_screen.sh" "My Library" ;;
  search)
    term="$(ask "Search title, author, genre, or status")"
    printf '%s\n' "$term" | "$ROOT/books/search_books.sh" | "$ROOT/ui/library_screen.sh" "Search Results"
    ;;
  add)
    title="$(ask "Title")"; author="$(ask "Author")"
    metadata="$(printf '%s | %s\n' "$title" "$author" | "$ROOT/books/fetch_book_metadata.sh")"
    IFS='|' read -r title author genre year link <<< "$metadata"
    genre_input="$(ask "Genre [$genre]")"; genre="${genre_input:-$genre}"
    year_input="$(ask "Year [$year]")"; year="${year_input:-$year}"
    status="$(choose "Reading status" want-to-read reading finished owned)"
    rating=""; [[ "$status" != finished ]] || rating="$(ask "Rating 1-5 (optional)")"
    "$ROOT/data/book_database.sh" add "$title" "$author" "$genre" "$year" "$status" "$rating" "$link"
    echo "Saved: $title by $author"
    ;;
  update)
    title="$(ask "Exact title")"
    action="$(choose "What should change?" status rating)"
    if [[ "$action" == status ]]; then
      value="$(choose "New status" want-to-read reading finished owned)"
      "$ROOT/data/book_database.sh" update-status "$title" "$value"
    else
      value="$(choose "New rating" 1 2 3 4 5)"
      "$ROOT/data/book_database.sh" update-rating "$title" "$value"
    fi
    echo "Updated: $title"
    ;;
  *) echo "Usage: $0 {browse|search|add|update}" >&2; exit 2 ;;
esac
