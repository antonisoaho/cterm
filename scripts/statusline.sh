#!/usr/bin/env bash
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PY=$(command -v python3 || command -v python)
[ -z "$PY" ] && exit 0
exec "$PY" "$DIR/statusline.py"
