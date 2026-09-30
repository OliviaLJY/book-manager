#!/usr/bin/env bash
set -euo pipefail
ROOT="${BOOK_MANAGER_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
options=("Browse Library" "Add Book" "Search Library" "Update Book" "Get Recommendations" "Quit")

if command -v gum >/dev/null 2>&1; then gum style --foreground 212 --bold "Personal Book Manager"; else echo "Personal Book Manager (install gum for the rich interface)"; fi
while true; do
  if command -v gum >/dev/null 2>&1; then
    choice="$(printf '%s\n' "${options[@]}" | gum choose --header 'What would you like to do?')" || exit 0
  else
    PS3='Choose an action: '
    select choice in "${options[@]}"; do break; done
  fi
  case "$choice" in
    "Browse Library") "$ROOT/workflows/manage_library.sh" browse ;;
    "Add Book") "$ROOT/workflows/manage_library.sh" add ;;
    "Search Library") "$ROOT/workflows/manage_library.sh" search ;;
    "Update Book") "$ROOT/workflows/manage_library.sh" update ;;
    "Get Recommendations") "$ROOT/workflows/get_recommendations.sh" ;;
    "Quit") echo "Happy reading!"; break ;;
    *) echo "Please choose a listed action." ;;
  esac
done
