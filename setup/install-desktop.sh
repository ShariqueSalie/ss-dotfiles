#!/usr/bin/env bash
# ------------------------------------------------------------
# Desktop install of ShariqueSalie/dotfiles
#
# Installs the official ML4W dotfiles installer and then runs it with
# this fork's manifest, so the resulting desktop carries the ss.
# customizations (statusbar, fastfetch banner, keybindings, ...).
#
# This needs a graphical Fedora / Arch / Ubuntu / openSUSE Tumbleweed
# system. For a headless server use setup/install-server.sh instead.
#
#   curl -fsSL https://raw.githubusercontent.com/ShariqueSalie/dotfiles/main/setup/install-desktop.sh | bash
#
# Environment:
#   MANIFEST_URL   manifest to install (default: this fork's rolling manifest)
#   INSTALLER_TAG  ml4w-dotfiles-installer tag (default: 0.3.1)
# ------------------------------------------------------------
set -euo pipefail

MANIFEST_URL="${MANIFEST_URL:-https://raw.githubusercontent.com/ShariqueSalie/dotfiles/main/hyprland-dotfiles.dotinst}"
INSTALLER_URL="https://github.com/mylinuxforwork/ml4w-dotfiles-installer.git"
INSTALLER_TAG="${INSTALLER_TAG:-0.3.1}"

say() { printf '\033[1;34m[dotfiles]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[dotfiles]\033[0m %s\n' "$*" >&2; }
die() { printf '\033[1;31m[dotfiles]\033[0m %s\n' "$*" >&2; exit 1; }

if [[ -z "${WAYLAND_DISPLAY:-}" && -z "${DISPLAY:-}" ]]; then
    warn "No graphical session detected."
    warn "These dotfiles are a Hyprland desktop. On a headless server run:"
    warn "  curl -fsSL https://raw.githubusercontent.com/ShariqueSalie/dotfiles/main/setup/install-server.sh | bash"
    warn "Continuing in 5 seconds (Ctrl+C to stop)..."
    sleep 5
fi

# --- base dependencies --------------------------------------------------
if command -v pacman >/dev/null; then
    say "Arch Linux detected"
    sudo pacman -S --needed --noconfirm git make curl jq
elif command -v dnf >/dev/null; then
    say "Fedora detected"
    sudo dnf install -y git make curl jq
elif command -v zypper >/dev/null; then
    say "openSUSE detected"
    sudo zypper install -y git make curl jq
elif command -v apt-get >/dev/null; then
    say "Ubuntu detected"
    sudo apt-get update
    sudo apt-get install -y git make curl jq
else
    die "Unsupported distribution. Install git, make, curl and jq manually."
fi

# --- install the ML4W installer app -------------------------------------
TEMP_DIR=$(mktemp -d -t ml4w-installer-XXXXXX)
trap 'rm -rf "$TEMP_DIR"' EXIT
say "cloning ml4w-dotfiles-installer $INSTALLER_TAG"
git clone --depth=1 --branch "$INSTALLER_TAG" -c advice.detachedHead=false "$INSTALLER_URL" "$TEMP_DIR"
make -C "$TEMP_DIR" install

export PATH="$HOME/.local/bin:$PATH"
command -v ml4w-dotfiles-installer >/dev/null ||
    die "ml4w-dotfiles-installer is not on PATH ($HOME/.local/bin)"

# --- install this fork --------------------------------------------------
say "installing ShariqueSalie/dotfiles from $MANIFEST_URL"
ml4w-dotfiles-installer --install "$MANIFEST_URL"

say "done. Log out and back in to start the new desktop."
