#!/usr/bin/env bash
set -euo pipefail
interests="${1:-}"
[[ -n "$interests" ]] || IFS= read -r interests || true
sleep 2
interests="$(printf '%s' "$interests" | tr '[:upper:]' '[:lower:]')"
case "$interests" in
  *technolog*|*computer*|*ai*) printf '%s\n' 'The Alignment Problem|Brian Christian|Technology|Explores the human choices inside machine learning' 'Code|Charles Petzold|Technology|Explains how computers work from first principles' ;;
  *history*|*politic*) printf '%s\n' 'The Dawn of Everything|David Graeber and David Wengrow|History|Challenges familiar stories about social history' 'The Warmth of Other Suns|Isabel Wilkerson|History|A deeply researched narrative of the Great Migration' ;;
  *art*|*creativ*|*design*) printf '%s\n' 'Ways of Seeing|John Berger|Art|Sharpens how you interpret visual culture' 'The Creative Act|Rick Rubin|Creativity|Practical reflections on creative attention' ;;
  *nature*|*environment*) printf '%s\n' 'Braiding Sweetgrass|Robin Wall Kimmerer|Nature|Joins ecology with Indigenous knowledge' 'Entangled Life|Merlin Sheldrake|Science|Reframes nature through the world of fungi' ;;
  *) printf '%s\n' 'Four Thousand Weeks|Oliver Burkeman|Philosophy|A humane approach to time and meaningful priorities' 'The Anthropocene Reviewed|John Green|Essays|Curious essays spanning science culture and daily life' ;;
esac
