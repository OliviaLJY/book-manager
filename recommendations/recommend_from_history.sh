#!/usr/bin/env bash
set -euo pipefail
ROOT="${BOOK_MANAGER_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
sleep 1
top_genre="$("$ROOT/data/book_database.sh" genres | awk 'NR==1 {$1=""; sub(/^ /,""); print; exit}')"
top_genre="$(printf '%s' "$top_genre" | tr '[:upper:]' '[:lower:]')"
case "$top_genre" in
  *science*fiction*) printf '%s\n' 'The Left Hand of Darkness|Ursula K. Le Guin|Science Fiction|Expands on the speculative fiction already in your library' 'Kindred|Octavia E. Butler|Science Fiction|A powerful historical variation on speculative fiction' ;;
  *psychology*|*behavior*) printf '%s\n' 'The Righteous Mind|Jonathan Haidt|Psychology|Builds on your interest in how people think' 'Mistakes Were Made (But Not by Me)|Carol Tavris and Elliot Aronson|Psychology|A practical look at cognitive dissonance' ;;
  *design*) printf '%s\n' 'The Design of Everyday Things|Don Norman|Design|A foundational extension of your design reading' 'Ruined by Design|Mike Monteiro|Design|Connects design practice with responsibility' ;;
  *) printf '%s\n' 'The Dispossessed|Ursula K. Le Guin|Science Fiction|A thoughtful character-driven classic' 'Braiding Sweetgrass|Robin Wall Kimmerer|Nature|Combines observation science and story' ;;
esac
