#!/usr/bin/env bash
set -euo pipefail

mode="${1:-Library}"
input="$(cat)"
if command -v gum >/dev/null 2>&1; then gum style --border rounded --padding '0 1' "$mode"; else printf '\n== %s ==\n' "$mode"; fi
if [[ -z "$input" ]]; then echo "No books found."; exit 0; fi
{
  printf 'TITLE\tAUTHOR\tGENRE\tYEAR\tSTATUS\tRATING\n'
  printf '%s\n' "$input" | awk -F '\t' 'BEGIN{OFS="\t"} {print $1,$2,$3,$4,$5,($6==""?"-":$6)}'
} | column -t -s $'\t'
