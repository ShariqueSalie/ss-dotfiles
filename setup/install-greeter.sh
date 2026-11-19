#!/usr/bin/env bash
# ------------------------------------------------------------
# dwm-s LightDM slick-greeter login screen
#
# Installs LightDM with the slick-greeter and deploys the same
# configuration as github.com/ShariqueSalie/dwm-s: the Nord wallpaper,
# a centred login panel, the MesloLGS Nerd Font and a clock.
#
# Everything it needs lives in setup/greeter/, so the install is
# self-contained and works offline once the packages are present.
#
# Run by setup/post.sh during a desktop install, or by hand:
#
#   bash setup/install-greeter.sh
#   bash setup/install-greeter.sh --dry-run
#   bash setup/install-greeter.sh --session hyprland
#
# Options:
#   --dry-run          show what would happen, change nothing
#   --no-packages      do not install lightdm / slick-greeter
#   --session NAME     default session (default: autodetect)
# ------------------------------------------------------------
set -euo pipefail

GREETER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/greeter"
FONT_DIR="$GREETER_DIR/fonts"

DRY_RUN=false
INSTALL_PACKAGES=true
SESSION=""

while (($# > 0)); do
    case "$1" in
        --dry-run) DRY_RUN=true ;;
        --no-packages) INSTALL_PACKAGES=false ;;
        --session)
            (($# >= 2)) || { echo "--session needs a value" >&2; exit 2; }
            SESSION="$2"
            shift
            ;;
        -h|--help) sed -n '2,22p' "${BASH_SOURCE[0]:-$0}" | sed 's/^# \{0,1\}//'; exit 0 ;;
        *) echo "unknown option: $1" >&2; exit 2 ;;
    esac
    shift
done

say() { printf '\033[1;34m[greeter]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[greeter]\033[0m %s\n' "$*" >&2; }
die() { printf '\033[1;31m[greeter]\033[0m %s\n' "$*" >&2; exit 1; }

run() {
    if $DRY_RUN; then
        printf '  would run: %s\n' "$*"
    else
        "$@"
    fi
}

SUDO=""
if [[ $(id -u) -ne 0 ]]; then
    command -v sudo >/dev/null || die "root or sudo is required"
    SUDO="sudo"
fi

LIGHTDM_CONF=""
cleanup() {
    [[ -n "$LIGHTDM_CONF" ]] && rm -f "$LIGHTDM_CONF"
}
trap cleanup EXIT

# --- pick the session to log into ---------------------------------------
# Prefer the Hyprland session this desktop install creates, then the uwsm
# variant, then dwm (when installed on a dwm-s machine).
if [[ -z "$SESSION" ]]; then
    for candidate in hyprland hyprland-uwsm dwm; do
        if [[ -f "/usr/share/wayland-sessions/$candidate.desktop" ||
              -f "/usr/share/xsessions/$candidate.desktop" ]]; then
            SESSION="$candidate"
            break
        fi
    done
fi
if [[ -z "$SESSION" ]]; then
    warn "no known desktop session found; the greeter will use its session menu"
else
    say "default session: $SESSION"
fi

# --- packages -----------------------------------------------------------
install_packages() {
    if [[ -x /usr/sbin/lightdm || -x /usr/bin/lightdm ]] &&
        [[ -f /usr/share/xgreeters/slick-greeter.desktop ]]; then
        say "lightdm and slick-greeter already installed"
        return 0
    fi
    if ! $INSTALL_PACKAGES; then
        warn "lightdm/slick-greeter missing and --no-packages was given"
        return 0
    fi
    say "installing lightdm and slick-greeter"
    if command -v dnf >/dev/null; then
        run $SUDO dnf install -y lightdm slick-greeter
    elif command -v apt-get >/dev/null; then
        run $SUDO apt-get update
        run $SUDO apt-get install -y lightdm slick-greeter
    elif command -v pacman >/dev/null; then
        run $SUDO pacman -S --needed --noconfirm lightdm lightdm-slick-greeter
    elif command -v zypper >/dev/null; then
        run $SUDO zypper install -y lightdm lightdm-slick-greeter ||
            run $SUDO zypper install -y lightdm slick-greeter
    else
        die "unsupported distribution; install lightdm and slick-greeter first"
    fi
}

# --- MesloLGS NF, system-wide so the greeter user can use it ------------
# The TTFs are bundled in setup/greeter/fonts; no download needed.
install_fonts() {
    [[ -d "$FONT_DIR" ]] || die "missing font directory: $FONT_DIR"
    if find /usr/share/fonts /usr/local/share/fonts -iname 'MesloLGS*NerdFont*' 2>/dev/null |
        grep -q .; then
        say "MesloLGS Nerd Font already installed system-wide"
        return 0
    fi
    say "installing MesloLGS Nerd Font to /usr/local/share/fonts/Meslo"
    run $SUDO install -d -m 0755 /usr/local/share/fonts/Meslo
    for font in "$FONT_DIR"/*.ttf; do
        run $SUDO install -m 0644 "$font" "/usr/local/share/fonts/Meslo/$(basename "$font")"
    done
    run $SUDO fc-cache -f >/dev/null
}

# --- config files -------------------------------------------------------
install_config() {
    local src="$1" dst="$2" mode="${3:-0644}"
    if [[ -f "$dst" ]] && cmp -s "$src" "$dst"; then
        return 0
    fi
    if [[ -e "$dst" ]]; then
        say "backing up $dst"
        run $SUDO cp -a "$dst" "$dst.$(date +%Y%m%d%H%M%S).bak"
    fi
    say "installing $dst"
    run $SUDO install -Dm"$mode" "$src" "$dst"
}

# --- make LightDM the display manager -----------------------------------
enable_lightdm() {
    # Disable the other greeters but never stop them: stopping the running
    # display manager would kill the current graphical session.
    for dm in gdm sddm lxdm xdm mdm slim wdm; do
        if systemctl is-enabled --quiet "$dm" 2>/dev/null; then
            say "disabling $dm"
            run $SUDO systemctl disable "$dm"
        fi
    done
    if [[ "$(systemctl get-default 2>/dev/null || true)" != "graphical.target" ]]; then
        say "setting the default boot target to graphical.target"
        run $SUDO systemctl set-default graphical.target
    fi
    say "enabling lightdm"
    run $SUDO systemctl enable lightdm
}

main() {
    [[ -f "$GREETER_DIR/slick-greeter.conf" ]] ||
        die "missing $GREETER_DIR/slick-greeter.conf"
    [[ -f "$GREETER_DIR/wallpaper.jpg" ]] ||
        die "missing $GREETER_DIR/wallpaper.jpg"

    # The dwm-s setup: [Seat:*] with the Fedora greeter name, no session
    # wrapper, and logind-check-graphical enabled.
    LIGHTDM_CONF=$(mktemp -t lightdm-conf-XXXXXX)
    {
        printf '[LightDM]\n'
        printf 'logind-check-graphical=true\n'
        printf '\n'
        printf '[Seat:*]\n'
        printf 'greeter-session=slick-greeter\n'
        [[ -n "$SESSION" ]] && printf 'user-session=%s\n' "$SESSION"
    } >"$LIGHTDM_CONF"

    install_packages
    install_fonts

    if ! $DRY_RUN &&
        [[ -f /etc/lightdm/lightdm.conf ]] &&
        cmp -s "$LIGHTDM_CONF" /etc/lightdm/lightdm.conf &&
        cmp -s "$GREETER_DIR/slick-greeter.conf" /etc/lightdm/slick-greeter.conf &&
        cmp -s "$GREETER_DIR/wallpaper.jpg" /usr/share/pixmaps/dwm-s.jpg &&
        systemctl is-enabled --quiet lightdm 2>/dev/null; then
        say "dwm-s LightDM greeter already installed"
        return 0
    fi

    install_config "$LIGHTDM_CONF" /etc/lightdm/lightdm.conf
    install_config "$GREETER_DIR/slick-greeter.conf" /etc/lightdm/slick-greeter.conf
    install_config "$GREETER_DIR/wallpaper.jpg" /usr/share/pixmaps/dwm-s.jpg

    $DRY_RUN || enable_lightdm

    # SELinux: keep the greeter able to read its config and wallpaper.
    if command -v restorecon >/dev/null; then
        run $SUDO restorecon /etc/lightdm/lightdm.conf \
            /etc/lightdm/slick-greeter.conf /usr/share/pixmaps/dwm-s.jpg
    fi

    if $DRY_RUN; then
        say "done (dry run: nothing was changed)"
    else
        say "done. Reboot to see the new login screen."
    fi
}

main "$@"
