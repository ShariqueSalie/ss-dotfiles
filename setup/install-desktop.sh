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
# Options:
#   --no-greeter   keep the existing login screen (no LightDM install)
#   --no-gaming    skip the Fedora gaming packages
#   --enable-fedora-gaming-repos
#                  approve RPM Fusion nonfree + the Gamescope COPR without asking
#
# Environment:
#   MANIFEST_URL   manifest to install (default: this fork's rolling manifest)
#   INSTALLER_TAG  ml4w-dotfiles-installer tag (default: 0.3.1)
# ------------------------------------------------------------
set -euo pipefail

MANIFEST_URL="${MANIFEST_URL:-https://raw.githubusercontent.com/ShariqueSalie/dotfiles/main/hyprland-dotfiles.dotinst}"
INSTALLER_URL="https://github.com/mylinuxforwork/ml4w-dotfiles-installer.git"
INSTALLER_TAG="${INSTALLER_TAG:-0.3.1}"
GAMING_URL="${GAMING_URL:-https://raw.githubusercontent.com/ShariqueSalie/dotfiles/main/setup/install-gaming.sh}"

INSTALL_GAMING=true
GAMING_REPOS=false

say() { printf '\033[1;34m[dotfiles]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[dotfiles]\033[0m %s\n' "$*" >&2; }
die() { printf '\033[1;31m[dotfiles]\033[0m %s\n' "$*" >&2; exit 1; }

usage() {
    cat <<'EOF'
Desktop install of ShariqueSalie/dotfiles: ML4W Hyprland, the dwm-s
LightDM login screen and the Fedora gaming packages.

Usage: install-desktop.sh [options]

Options:
  --no-greeter                  keep the existing login screen
  --no-gaming                   skip the Fedora gaming packages
  --enable-fedora-gaming-repos  approve RPM Fusion nonfree and the
                                Gamescope COPR without asking
  -h, --help                    show this help

Environment:
  MANIFEST_URL   manifest to install (default: this fork's rolling manifest)
  INSTALLER_TAG  ml4w-dotfiles-installer tag (default: 0.3.1)
EOF
}

while (($# > 0)); do
    case "$1" in
        --no-greeter) export ML4W_NO_GREETER=1 ;;
        --no-gaming) INSTALL_GAMING=false ;;
        --enable-fedora-gaming-repos) GAMING_REPOS=true ;;
        -h|--help) usage; exit 0 ;;
        *) die "unknown option: $1" ;;
    esac
    shift
done

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

# The ML4W installer asks "Do you want to proceed with the installation?"
# through gum, which reads stdin. With the documented curl | bash one-liner
# stdin is the pipe and already at EOF, gum treats that as "no" and the
# installer exits with "Installation cancelled by user" after only checking
# dependencies. Skip its prompt for a non-interactive stdin; a normal
# interactive run still asks.
if [ ! -t 0 ]; then
    export ML4W_YES=1
fi

ml4w-dotfiles-installer --install "$MANIFEST_URL"

# The upstream installer exits 0 even when its prompt is answered "no" (or
# reads EOF), so it can look like a successful run while nothing was
# installed. Fail loudly instead of printing "done" for a no-op.
if [ ! -e "$HOME/.config/ml4w/scripts/ml4w-restart-quickshell" ]; then
    die "the ML4W installer did not install the dotfiles. See the log in ~/.local/state/ml4w-dotfiles-installer/logs"
fi

# --- Fedora gaming packages (the dwm-s gaming profile) -----------------
if $INSTALL_GAMING && [[ -f /etc/fedora-release ]] && [[ "$(uname -m)" == x86_64 ]]; then
    say "installing Fedora gaming packages (dwm-s profile)"
    gaming_args=()
    $GAMING_REPOS && gaming_args+=(--enable-repos)
    curl -fsSL "$GAMING_URL" -o "$TEMP_DIR/install-gaming.sh"
    bash "$TEMP_DIR/install-gaming.sh" "${gaming_args[@]}" ||
        warn "gaming packages were skipped or some were unavailable"
elif $INSTALL_GAMING; then
    say "gaming packages are Fedora x86_64 only; skipping"
fi

say "done. Log out and back in to start the new desktop."
