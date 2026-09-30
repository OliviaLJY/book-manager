#!/usr/bin/env bash
# Input/output: title|author -> title|author|genre|year|link
set -euo pipefail

input="${1:-}"
[[ -n "$input" ]] || IFS= read -r input || true
IFS='|' read -r raw_title raw_author <<< "$input"
title="$(printf '%s' "${raw_title:-}" | sed 's/^ *//;s/ *$//')"
author="$(printf '%s' "${raw_author:-}" | sed 's/^ *//;s/ *$//')"
[[ -n "$title" && -n "$author" ]] || { echo "Expected: Title | Author" >&2; exit 2; }

genre="General"; year=""
lookup="$(printf '%s %s' "$title" "$author" | tr '[:upper:]' '[:lower:]')"
case "$lookup" in
  *dune*herbert*) genre="Science Fiction"; year="1965" ;;
  *parable*butler*) genre="Science Fiction"; year="1993" ;;
  *educated*westover*) genre="Memoir"; year="2018" ;;
  *thinking*fast*slow*kahneman*) genre="Psychology"; year="2011" ;;
  *design*everyday*norman*) genre="Design"; year="1988" ;;
  *braiding*sweetgrass*kimmerer*) genre="Nature"; year="2013" ;;
  *left*hand*darkness*leguin*) genre="Science Fiction"; year="1969" ;;
esac

query="$(printf '%s %s' "$title" "$author" | sed 's/ /+/g;s/[^A-Za-z0-9+_-]//g')"
printf '%s|%s|%s|%s|https://openlibrary.org/search?q=%s\n' "$title" "$author" "$genre" "$year" "$query"
