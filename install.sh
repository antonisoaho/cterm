#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="${1:-$HOME/.local/bin}"

mkdir -p "$INSTALL_DIR"
ln -sf "$REPO/cterm" "$INSTALL_DIR/cterm"
chmod +x "$REPO/cterm"

echo "Installed: $INSTALL_DIR/cterm -> $REPO/cterm"

if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
  echo ""
  echo "Add $INSTALL_DIR to your PATH:"
  echo "  echo 'export PATH=\"\$HOME/.local/bin:\$PATH\"' >> ~/.bashrc"
  echo "  echo 'export PATH=\"\$HOME/.local/bin:\$PATH\"' >> ~/.zshrc"
fi
