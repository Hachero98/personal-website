#!/usr/bin/env bash
# Vercel build script — downloads the Quarto CLI and renders the site.
set -euo pipefail

QUARTO_VERSION="1.9.37"
QUARTO_TARBALL="quarto-${QUARTO_VERSION}-linux-amd64.tar.gz"
QUARTO_URL="https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_VERSION}/${QUARTO_TARBALL}"

echo "==> Build environment"
uname -a
echo "PWD: $PWD"
ls -la

echo "==> Downloading Quarto ${QUARTO_VERSION}"
curl -fsSL "$QUARTO_URL" -o quarto.tar.gz

echo "==> Extracting"
tar -xzf quarto.tar.gz

echo "==> Locating quarto binary"
QUARTO_BIN="$(find . -maxdepth 4 -type f -name quarto -perm -u+x 2>/dev/null | head -1 || true)"
if [ -z "$QUARTO_BIN" ]; then
  echo "ERROR: quarto binary not found after extraction"
  echo "Top-level entries:"
  ls -la
  echo "Directory tree (depth 3):"
  find . -maxdepth 3 -type d
  exit 1
fi

QUARTO_DIR="$(cd "$(dirname "$QUARTO_BIN")" && pwd)"
echo "==> Found quarto at: $QUARTO_BIN"
echo "==> Adding to PATH: $QUARTO_DIR"
export PATH="$QUARTO_DIR:$PATH"

echo "==> Quarto version:"
quarto --version

echo "==> Rendering site"
quarto render

echo "==> Build complete; output in _site/"
ls -la _site | head -20
