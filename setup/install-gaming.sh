#!/usr/bin/env bash
# ------------------------------------------------------------
# Fedora gaming packages from dwm-s
#
# Mirrors the gaming part of github.com/ShariqueSalie/dwm-s:
#   * RPM Fusion nonfree for Steam
#   * the christitustech/copr-fedora COPR for the patched Gamescope
#     (Fedora 45 already ships Gamescope, so the COPR is skipped)
#   * steam gamescope gamemode mangohud, 64- and 32-bit
#   * GameMode tuning access for the invoking user
#
# Only Fedora on x86_64 is supported, exactly like dwm-s.
#
# Options:
#   --dry-run        show what would happen, change nothing
#   --enable-repos   approve RPM Fusion nonfree and the COPR without asking
#   --user NAME      user to add to the gamemode group
#   --no-gamemode    do not touch the gamemode group
# ------------------------------------------------------------
set -euo pipefail

DRY_RUN=false
REPOS_APPROVED=false
TARGET_USER="${SUDO_USER:-$(id -un)}"
CONFIGURE_GAMEMODE=true

while (($# > 0)); do
    case "$1" in
        --dry-run) DRY_RUN=true ;;
        --enable-repos) REPOS_APPROVED=true ;;
        --no-gamemode) CONFIGURE_GAMEMODE=false ;;
        --user)
            (($# >= 2)) || { echo "--user needs a value" >&2; exit 2; }
            TARGET_USER="$2"
            shift
            ;;
        -h|--help) sed -n '2,19p' "${BASH_SOURCE[0]:-$0}" | sed 's/^# \{0,1\}//'; exit 0 ;;
        *) echo "unknown option: $1" >&2; exit 2 ;;
    esac
    shift
done

say() { printf '\033[1;34m[gaming]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[gaming]\033[0m %s\n' "$*" >&2; }
ok() { printf '\033[1;32m[gaming]\033[0m %s\n' "$*"; }
die() { printf '\033[1;31m[gaming]\033[0m %s\n' "$*" >&2; exit 1; }

run() {
    if $DRY_RUN; then
        printf '  would run: %s\n' "$*"
    else
        "$@"
    fi
}

# --- only Fedora on x86_64, like dwm-s --------------------------------
[[ -f /etc/fedora-release ]] || { warn "not Fedora; skipping gaming packages"; exit 0; }
[[ "$(uname -m)" == x86_64 ]] || { warn "not x86_64; skipping gaming packages"; exit 0; }

SUDO=""
if [[ $(id -u) -ne 0 ]]; then
    command -v sudo >/dev/null || die "root or sudo is required"
    SUDO="sudo"
fi

FEDORA_GAMING_COPR="christitustech/copr-fedora"
PACKAGES=(steam gamescope gamemode.x86_64 gamemode.i686 mangohud.x86_64 mangohud.i686)

fedora_release() {
    local release
    release=$(rpm -E '%fedora' 2>/dev/null || true)
    if [[ -z "$release" || ! "$release" =~ ^[0-9]+$ ]]; then
        # shellcheck disable=SC1091
        release=$(. /etc/os-release && printf '%s' "${VERSION_ID%%.*}")
    fi
    printf '%s' "$release"
}

# --- third-party repositories -----------------------------------------
has_tty() {
    { : >/dev/tty; } 2>/dev/null
}

approve_repositories() {
    $REPOS_APPROVED && return 0
    if ! has_tty; then
        warn "third-party repositories were not approved"
        warn "re-run with --enable-repos to install Steam, Gamescope, GameMode and MangoHud"
        return 1
    fi
    local release answer
    release=$(fedora_release)
    if [[ "$release" == 45 ]]; then
        printf 'Enable RPM Fusion nonfree for Fedora gaming packages? [y/N] ' >/dev/tty
    else
        printf 'Enable the %s COPR and RPM Fusion nonfree for Fedora gaming packages? [y/N] ' \
            "$FEDORA_GAMING_COPR" >/dev/tty
    fi
    read -r answer </dev/tty || answer=""
    case "$answer" in
        y|Y|yes|YES) return 0 ;;
        *) warn "declined; skipping Steam, Gamescope, GameMode and MangoHud"; return 1 ;;
    esac
}

configure_repositories() {
    local release plugin
    release=$(fedora_release)

    say "enabling RPM Fusion nonfree"
    run $SUDO dnf install -y \
        "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${release}.noarch.rpm" ||
        { warn "could not enable RPM Fusion nonfree; skipping gaming packages"; return 1; }

    if [[ "$release" == 45 ]]; then
        say "Fedora 45 already ships Gamescope; the COPR is not needed"
        return 0
    fi

    if ! dnf copr --help >/dev/null 2>&1; then
        say "installing a DNF COPR plugin"
        for plugin in dnf5-plugins dnf-plugins-core; do
            if run $SUDO dnf install -y "$plugin" >/dev/null 2>&1; then
                break
            fi
        done
        if ! $DRY_RUN && ! dnf copr --help >/dev/null 2>&1; then
            warn "no working DNF COPR plugin; skipping gaming packages"
            return 1
        fi
    fi

    say "enabling $FEDORA_GAMING_COPR"
    run $SUDO dnf copr enable -y "$FEDORA_GAMING_COPR" ||
        { warn "could not enable $FEDORA_GAMING_COPR; skipping gaming packages"; return 1; }
}

# --- packages ----------------------------------------------------------
install_gaming_packages() {
    say "installing ${PACKAGES[*]}"
    if $DRY_RUN; then
        run $SUDO dnf install -y "${PACKAGES[@]}"
        return 0
    fi
    if $SUDO dnf install -y "${PACKAGES[@]}"; then
        ok "gaming packages installed"
        return 0
    fi
    # Some spins lack the 32-bit variants; install what exists.
    local package status=0
    for package in "${PACKAGES[@]}"; do
        if ! $SUDO dnf install -y "$package"; then
            warn "unavailable: $package"
            status=1
        fi
    done
    return $status
}

# --- GameMode tuning access -------------------------------------------
configure_gamemode_access() {
    $CONFIGURE_GAMEMODE || return 0
    if $DRY_RUN; then
        say "would add $TARGET_USER to the gamemode group (if it exists)"
        return 0
    fi
    if ! getent group gamemode >/dev/null 2>&1; then
        warn "the gamemode group does not exist; skipping tuning access"
        return 0
    fi
    if id -nG "$TARGET_USER" 2>/dev/null | tr ' ' '\n' | grep -Fxq gamemode; then
        ok "$TARGET_USER already has GameMode tuning access"
        return 0
    fi
    say "adding $TARGET_USER to the gamemode group"
    run $SUDO usermod -aG gamemode "$TARGET_USER"
    warn "log out and back in before using GameMode privileged tuning"
}

if approve_repositories; then
    if configure_repositories; then
        install_gaming_packages || warn "some gaming packages were unavailable"
        configure_gamemode_access
    fi
fi

if $DRY_RUN; then
    say "done (dry run: nothing was changed)"
else
    say "done."
fi
