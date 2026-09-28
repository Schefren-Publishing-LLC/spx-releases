#!/bin/sh
set -eu

REPO="${SPX_REPO:-Schefren-Publishing-LLC/spx-releases}"
ENV_NAME="${SPX_ENV:-production}"
INSTALL_DIR="${SPX_INSTALL_DIR:-$HOME/.local/bin}"
VERSION="${SPX_VERSION:-latest}"

say() { printf '%s\n' "$*" >&2; }
die() { say "install.sh: $*"; exit 1; }

os=$(uname -s | tr '[:upper:]' '[:lower:]')
arch=$(uname -m)
case "$arch" in
  x86_64|amd64) arch=amd64 ;;
  arm64|aarch64) arch=arm64 ;;
  *) die "unsupported architecture: $arch" ;;
esac
case "$os" in
  darwin|linux) ;;
  *) die "unsupported OS: $os (on Windows, download the .zip from the releases page and run: spx setup --env $ENV_NAME)" ;;
esac
asset="spx_${os}_${arch}.tar.gz"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT INT TERM

command -v curl >/dev/null 2>&1 || die "need curl to download the release"
if [ "$VERSION" = latest ]; then
  base="https://github.com/$REPO/releases/latest/download"
else
  base="https://github.com/$REPO/releases/download/$VERSION"
fi
say "Downloading $asset from $base…"
curl -fsSL "$base/$asset" -o "$tmp/$asset" || die "download failed ($base/$asset)"
curl -fsSL "$base/checksums.txt" -o "$tmp/checksums.txt" || die "checksums.txt download failed"

expected=$(grep " ./$asset\$" "$tmp/checksums.txt" | awk '{print $1}')
[ -n "$expected" ] || die "no checksum for $asset in checksums.txt"
if command -v sha256sum >/dev/null 2>&1; then
  actual=$(sha256sum "$tmp/$asset" | awk '{print $1}')
else
  actual=$(shasum -a 256 "$tmp/$asset" | awk '{print $1}')
fi
[ "$expected" = "$actual" ] || die "checksum mismatch for $asset (expected $expected, got $actual)"
say "Checksum verified (sha256 $actual)."

tar -xzf "$tmp/$asset" -C "$tmp" spx
mkdir -p "$INSTALL_DIR"
install -m 0755 "$tmp/spx" "$INSTALL_DIR/spx"
display_dir="$INSTALL_DIR"
case "$INSTALL_DIR" in "$HOME"/*) display_dir="~${INSTALL_DIR#"$HOME"}" ;; esac
say ""
say "Installed $("$INSTALL_DIR/spx" version) to $display_dir/spx"

case ":$PATH:" in
  *":$INSTALL_DIR:"*) ;;
  *)
    shell_name=$(basename "${SHELL:-sh}")
    say ""
    say "NOTE: $display_dir is not on your PATH, so 'spx' will not be found by you or by agents."
    case "$shell_name" in
      zsh)
        say "Add it for zsh (macOS default) and reload:"
        say "  echo 'export PATH=\"\$HOME/.local/bin:\$PATH\"' >> ~/.zshrc && source ~/.zshrc" ;;
      bash)
        if [ "$os" = darwin ]; then rc=~/.bash_profile; else rc=~/.bashrc; fi
        say "Add it for bash and reload:"
        say "  echo 'export PATH=\"\$HOME/.local/bin:\$PATH\"' >> $rc && source $rc" ;;
      fish)
        say "Add it for fish:"
        say "  fish_add_path $display_dir" ;;
      *)
        say "Add this line to your shell's startup file, then open a new terminal:"
        say "  export PATH=\"$display_dir:\$PATH\"" ;;
    esac
    [ "$INSTALL_DIR" = "$HOME/.local/bin" ] || say "(adjust the path above if you changed SPX_INSTALL_DIR: $display_dir)"
    say ""
    ;;
esac

"$INSTALL_DIR/spx" setup --env "$ENV_NAME" "$@"
