#!/usr/bin/env bash
set -euo pipefail
ROOT="${BOOK_MANAGER_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
results_file="${1:?results file required}"

[[ -s "$results_file" ]] || { echo "No new recommendations found."; exit 0; }
if command -v gum >/dev/null 2>&1; then gum style --border double --padding '0 1' "Your shortlist"; else echo "== Your shortlist =="; fi
awk -F'|' '{printf "%d. %s — %s [%s]\n   %s\n", NR,$1,$2,$3,$4}' "$results_file"

if command -v gum >/dev/null 2>&1; then
  answer="$(printf 'Not now\nSave a recommendation\n' | gum choose --header 'Next step')"
else
  read -r -p "Save one? Enter its number, or press Enter to skip: " answer
fi
[[ "$answer" != "Not now" && -n "$answer" ]] || exit 0
if [[ "$answer" == "Save a recommendation" ]]; then
  number="$(gum input --prompt 'Recommendation number: ')"
else number="$answer"; fi
[[ "$number" =~ ^[1-5]$ ]] || { echo "Skipped (not a valid number)."; exit 0; }
line="$(sed -n "${number}p" "$results_file")"; [[ -n "$line" ]] || { echo "No recommendation $number."; exit 0; }
IFS='|' read -r title author genre reason <<< "$line"
"$ROOT/data/book_database.sh" add "$title" "$author" "$genre" "" "want-to-read" "" ""
echo "Saved $title to your want-to-read list."
