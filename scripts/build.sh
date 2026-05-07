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

echo "==> Git status before checkout"
git -C "$PWD" log -1 --stat 2>&1 | head -25 || true
echo "Tracked files at HEAD:"
git -C "$PWD" ls-tree -r HEAD --name-only 2>&1 | head -30 || true

echo "==> Forcing git checkout to materialize tracked files"
# Vercel's clone sometimes leaves the working tree unpopulated.
# A no-op checkout is harmless if files are already present.
git -C "$PWD" checkout -- . 2>&1 || echo "(checkout returned non-zero)"

echo "==> Working directory after checkout"
ls -la
echo "Project files:"
find . -maxdepth 2 -type f \( -name "*.qmd" -o -name "_quarto.yml" -o -name "*.scss" \) 2>&1 | head -20

echo "==> Setting writable cache dirs inside the project"
mkdir -p ./_tmp ./_cache/deno ./_cache/xdg
export TMPDIR="$PWD/_tmp"
export DENO_DIR="$PWD/_cache/deno"
export XDG_CACHE_HOME="$PWD/_cache/xdg"
export XDG_DATA_HOME="$PWD/_cache/xdg"
export HOME="${HOME:-$PWD/_cache}"

# Install Quarto OUTSIDE the project root. If we extract the tarball inside
# $PWD, `quarto render` will recurse into quarto-${VERSION}/share/... and try
# to compile Quarto's own template .qmd files (which contain EJS shortcodes
# like `<%= filesafename %>`) — that's the build failure we hit before.
QUARTO_INSTALL_DIR="/tmp/quarto-install"
mkdir -p "$QUARTO_INSTALL_DIR"

# Belt-and-braces: if a previous run left a quarto-* folder inside the
# project (e.g. from a cached checkout), nuke it before rendering.
rm -rf "$PWD"/quarto-*/ "$PWD"/quarto.tar.gz

echo "==> Downloading Quarto ${QUARTO_VERSION}"
curl -fsSL "$QUARTO_URL" -o "$QUARTO_INSTALL_DIR/quarto.tar.gz"
ls -la "$QUARTO_INSTALL_DIR/quarto.tar.gz"

echo "==> Extracting to $QUARTO_INSTALL_DIR"
tar -xzf "$QUARTO_INSTALL_DIR/quarto.tar.gz" -C "$QUARTO_INSTALL_DIR"

echo "==> Locating quarto binary"
QUARTO_BIN="$(find "$QUARTO_INSTALL_DIR" -maxdepth 4 -type f -name quarto -perm -u+x 2>/dev/null | head -1 || true)"
if [ -z "$QUARTO_BIN" ]; then
  echo "ERROR: quarto binary not found after extraction"
  ls -la "$QUARTO_INSTALL_DIR"
  find "$QUARTO_INSTALL_DIR" -maxdepth 3 -type d
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
