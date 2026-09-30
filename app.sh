#!/usr/bin/env bash
set -euo pipefail

APP_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export BOOK_MANAGER_ROOT="$APP_ROOT"

"$APP_ROOT/data/book_database.sh" init
"$APP_ROOT/ui/main_menu.sh"
