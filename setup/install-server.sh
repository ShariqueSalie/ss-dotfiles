#!/usr/bin/env bash
# ------------------------------------------------------------
# Headless server install of ShariqueSalie/dotfiles
#
# Installs only the CLI parts of these dotfiles: the modular bash
# setup (aliases, prompt, fastfetch banner), btop, vim and the ss.
# logo used by fastfetch. No Hyprland, no quickshell, no GUI.
#
#   curl -fsSL https://raw.githubusercontent.com/ShariqueSalie/dotfiles/main/setup/install-server.sh | bash
#
# Options:
#   --dry-run        print what would happen, change nothing
#   --no-packages    skip package installation
#   --repo <dir>     install from an existing clone
#   --ref <branch>   branch to download when not run from a clone (default: main)
# ------------------------------------------------------------
set -euo pipefail

REPO_URL="https://github.com/ShariqueSalie/dotfiles.git"
REF="main"
DRY_RUN=false
INSTALL_PACKAGES=true
REPO_DIR=""

usage() {
    cat <<'EOF'
usage: install-server.sh [options]

  --dry-run        print what would happen, change nothing
  --no-packages    skip package installation
  --repo <dir>     install from an existing clone
  --ref <branch>   branch to download when not run from a clone (default: main)
  -h, --help       show this help
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run) DRY_RUN=true ;;
        --no-packages) INSTALL_PACKAGES=false ;;
        --repo) REPO_DIR="${2:?--repo needs a path}"; shift ;;
        --ref) REF="${2:?--ref needs a branch}"; shift ;;
        -h|--help) usage; exit 0 ;;
        *) echo "unknown option: $1" >&2; usage >&2; exit 1 ;;
    esac
    shift
done

say() { printf '\033[1;34m[dotfiles]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[dotfiles]\033[0m %s\n' "$*" >&2; }
die() { printf '\033[1;31m[dotfiles]\033[0m %s\n' "$*" >&2; exit 1; }

run() {
    if $DRY_RUN; then
        printf '  would run: %s\n' "$*"
    else
        "$@"
    fi
}

# --- packages -----------------------------------------------------------
# This runs before the download on purpose: a minimal server may not have
# git or curl yet, and dnf/apt can install them.
if $INSTALL_PACKAGES; then
    if ! command -v dnf >/dev/null; then
        warn "dnf not found; skipping package install (this repo targets Fedora)"
    else
        SUDO=""
        [[ $(id -u) -ne 0 ]] && SUDO="sudo"

        say "installing CLI packages with dnf"
        # RHEL needs CRB/EPEL for fastfetch and eza; a partial failure is
        # reported but does not stop the dotfiles installation.
        run $SUDO dnf install -y git curl tar fastfetch eza btop neovim zsh ||
            warn "some packages failed (on RHEL enable CRB/EPEL for eza/fastfetch)"
    fi
fi

# --- locate the dotfiles ------------------------------------------------
# Started from a clone, setup/../dotfiles is the payload. Piped through
# curl there is no clone, so download the branch tarball instead.
SCRIPT_DIR=""
if [[ -n "${BASH_SOURCE[0]:-}" && -f "${BASH_SOURCE[0]}" ]]; then
    SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
fi

cleanup_dir=""
if [[ -z "$REPO_DIR" ]]; then
    if [[ -n "$SCRIPT_DIR" && -d "$SCRIPT_DIR/../dotfiles/.config" ]]; then
        REPO_DIR=$(cd "$SCRIPT_DIR/.." && pwd)
        say "using local clone at $REPO_DIR"
    else
        if $DRY_RUN; then
            say "would download $REPO_URL ($REF) (dry run)"
            say "re-run from a clone or without --dry-run to try it for real"
            exit 0
        fi
        cleanup_dir=$(mktemp -d -t ss-dotfiles-XXXXXX)
        trap 'rm -rf "$cleanup_dir"' EXIT
        if command -v git >/dev/null; then
            say "downloading $REPO_URL ($REF)"
            git clone --quiet --depth=1 --branch "$REF" "$REPO_URL" "$cleanup_dir/repo"
            REPO_DIR="$cleanup_dir/repo"
        else
            # No git: fetch the branch tarball with whatever is available.
            command -v curl >/dev/null && command -v tar >/dev/null ||
                die "git (or curl and tar) is required to download the dotfiles"
            say "downloading $REPO_URL ($REF) as a tarball"
            curl -fsSL "https://codeload.github.com/ShariqueSalie/dotfiles/tar.gz/refs/heads/$REF" \
                -o "$cleanup_dir/repo.tar.gz"
            tar -xzf "$cleanup_dir/repo.tar.gz" -C "$cleanup_dir"
            REPO_DIR="$cleanup_dir/dotfiles-$REF"
        fi
    fi
fi
SRC="$REPO_DIR/dotfiles"
[[ -f "$SRC/.bashrc" ]] || die "$SRC does not look like the dotfiles repo"

# --- prompt -------------------------------------------------------------
if ! command -v oh-my-posh >/dev/null 2>&1; then
    say "installing oh-my-posh into ~/.local/bin"
    if $DRY_RUN; then
        printf '  would run: curl -fsSL https://ohmyposh.dev/install.sh | bash -s -- -d %s\n' "$HOME/.local/bin"
    else
        mkdir -p "$HOME/.local/bin"
        curl -fsSL https://ohmyposh.dev/install.sh | bash -s -- -d "$HOME/.local/bin" ||
            warn "oh-my-posh install failed; the prompt in 20-customization will complain"
    fi
fi

# --- configs ------------------------------------------------------------
# Only what works without a display. The fastfetch config points at the ss.
# logo under .config/ml4w/assets, so that single asset comes along.
PATHS=(
    ".bashrc"
    ".config/bashrc"
    ".config/fastfetch"
    ".config/btop"
    ".config/vim"
    ".config/ohmyposh"
    ".config/ml4w/assets/ss-logo.png"
)

BACKUP="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
$DRY_RUN || mkdir -p "$BACKUP"

copy_path() {
    local rel="$1" src="$SRC/$1" dst="$HOME/$1"
    if [[ ! -e "$src" ]]; then
        warn "missing $rel in the repo, skipping"
        return
    fi
    if [[ -e "$dst" || -L "$dst" ]]; then
        local b="$BACKUP/$rel"
        say "backing up ~/$rel"
        run mkdir -p "$(dirname "$b")"
        run cp -a "$dst" "$b"
        run rm -rf "$dst"
    fi
    say "installing ~/$rel"
    run mkdir -p "$(dirname "$dst")"
    run cp -a "$src" "$dst"
}

for p in "${PATHS[@]}"; do
    copy_path "$p"
done

say "done"
if $DRY_RUN; then
    say "(dry run: nothing was changed)"
fi
cat <<'EOF'

Open a new shell (or run: exec bash) to load the prompt, aliases and the
ss. banner.

Notes:
  * ls/ll use eza. If the package was unavailable, install it and the
    aliases start working.
  * This is the CLI-only install. The Hyprland/quickshell desktop is not
    installed here; use setup/install-desktop.sh on a graphical machine.
  * Existing files were backed up under ~/.dotfiles-backup/.
EOF
