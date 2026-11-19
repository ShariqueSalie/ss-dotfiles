#!/usr/bin/env bash
#
# Open the web browser. SUPER+B, the bar's browser button and the quicklinks
# all run this file; ML4W Settings edits it too.
#
# Fedora installs Brave Origin (setup/packages/packages-fedora) and makes it
# the default browser; the other distributions install Firefox. The first
# browser in the list below that is actually installed is used, so a machine
# where the default was swapped keeps working without editing this file.

set -u

if [ -n "${BROWSER:-}" ]; then
    read -r -a configured <<< "$BROWSER"
    if command -v "${configured[0]}" >/dev/null 2>&1; then
        exec "${configured[@]}" "$@"
    fi
fi

for candidate in brave-origin-stable firefox brave-browser-stable chromium \
                 google-chrome-stable microsoft-edge-stable vivaldi-stable \
                 falkon qutebrowser; do
    if command -v "$candidate" >/dev/null 2>&1; then
        exec "$candidate" "$@"
    fi
done

echo "browser.sh: no web browser found (install brave-origin or firefox, or edit this file)" >&2
if command -v notify-send >/dev/null 2>&1; then
    notify-send "Browser" \
        "No web browser found. Install one or edit ~/.config/ml4w/settings/browser.sh"
fi
exit 1
