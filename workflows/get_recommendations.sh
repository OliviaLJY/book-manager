#!/usr/bin/env bash
set -euo pipefail
ROOT="${BOOK_MANAGER_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
interests="${1:-}"
if [[ -z "$interests" ]]; then
  if command -v gum >/dev/null 2>&1; then interests="$(gum input --prompt 'Current interests: ')"; else read -r -p 'Current interests: ' interests; fi
fi

work_dir="$(mktemp -d "${TMPDIR:-/tmp}/book-recs.XXXXXX")"
trap 'rm -rf "$work_dir"' EXIT

"$ROOT/recommendations/recommend_from_history.sh" > "$work_dir/history" & history_pid=$!
"$ROOT/recommendations/recommend_from_interests.sh" "$interests" > "$work_dir/interests" & interests_pid=$!
"$ROOT/recommendations/recommend_for_discovery.sh" > "$work_dir/discovery" & discovery_pid=$!
pids=("$history_pid" "$interests_pid" "$discovery_pid")

started=$SECONDS
while kill -0 "${pids[@]}" 2>/dev/null; do
  printf '\rThinking in parallel%s (%ss)' "$(printf '%*s' "$(((SECONDS-started)%4))" '' | tr ' ' '.')" "$((SECONDS-started))"
  sleep 0.2
done
wait "$history_pid"; wait "$interests_pid"; wait "$discovery_pid"
printf '\rRecommendation agents finished in %ss.     \n' "$((SECONDS-started))"

# This is the central composition pipeline: three streams become one refined list.
cat "$work_dir/history" "$work_dir/interests" "$work_dir/discovery" |
  "$ROOT/recommendations/refine_recommendations.sh" > "$work_dir/final"
"$ROOT/ui/recommendations_screen.sh" "$work_dir/final"
