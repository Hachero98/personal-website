#!/usr/bin/env bash
# Vercel build script — downloads the Quarto CLI and renders the site.
# `set -x` traces every command into the build log so silent failures are visible.
set -euxo pipefail

QUARTO_VERSION="1.9.37"
QUARTO_TARBALL="quarto-${QUARTO_VERSION}-linux-amd64.tar.gz"
QUARTO_URL="https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_VERSION}/${QUARTO_TARBALL}"

echo "==> Build environment"
uname -a
echo "PWD: $PWD"
echo "User: $(id -un)"
ls -la
df -h "$PWD" /tmp 2>&1 || true

echo "==> Setting writable cache dirs inside the project"
mkdir -p ./_tmp ./_cache/deno ./_cache/xdg
export TMPDIR="$PWD/_tmp"
export DENO_DIR="$PWD/_cache/deno"
export XDG_CACHE_HOME="$PWD/_cache/xdg"
export XDG_DATA_HOME="$PWD/_cache/xdg"
export HOME="${HOME:-$PWD/_cache}"

echo "==> Downloading Quarto ${QUARTO_VERSION}"
curl -fsSL "$QUARTO_URL" -o quarto.tar.gz
ls -la quarto.tar.gz

echo "==> Extracting"
tar -xzf quarto.tar.gz

echo "==> Locating quarto binary"
QUARTO_BIN="$(find . -maxdepth 4 -type f -name quarto -perm -u+x 2>/dev/null | head -1 || true)"
if [ -z "$QUARTO_BIN" ]; then
  echo "ERROR: quarto binary not found after extraction"
  ls -la
  find . -maxdepth 3 -type d
  exit 1
fi

QUARTO_DIR="$(cd "$(dirname "$QUARTO_BIN")" && pwd)"
echo "==> Found quarto at: $QUARTO_BIN"
export PATH="$QUARTO_DIR:$PATH"

echo "==> quarto --version"
quarto --version

echo "==> quarto check (diagnostic; non-fatal)"
quarto check 2>&1 || echo "(quarto check returned non-zero — continuing)"

echo "==> Rendering site"
if ! quarto render 2>&1; then
  rc=$?
  echo "ERROR: quarto render failed with exit code $rc"
  echo "---- _site (if produced) ----"
  ls -la _site 2>&1 || true
  echo "---- .quarto cache ----"
  ls -la .quarto 2>&1 || true
  echo "---- _cache contents ----"
  find _cache -maxdepth 3 -type f 2>&1 | head -40 || true
  exit "$rc"
fi

echo "==> Build complete; _site contents:"
ls -la _site | head -20
