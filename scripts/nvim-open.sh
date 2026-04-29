#!/usr/bin/env bash
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PY=$(command -v python3 || command -v python)
[ -z "$PY" ] && exit 0
filepath=$("$PY" "$DIR/nvim-open.py")
[ -z "$filepath" ] && exit 0
nvim --server "${CTERM_NVIM_ADDR:-127.0.0.1:6666}" --remote "$filepath" 2>/dev/null || true
