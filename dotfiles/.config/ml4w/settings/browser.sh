#!/usr/bin/env bash
#
# Open the web browser. SUPER+B, the bar's browser button and the quicklinks
# all run this file; ML4W Settings edits it too.
#
# setup/packages installs Firefox, so it stays first and a fresh machine works
# without touching this file. When Firefox is not installed (for example on a
# machine that uses Brave Origin instead) the first installed browser from the
# list below is used.

set -u

if [ -n "${BROWSER:-}" ]; then
    read -r -a configured <<< "$BROWSER"
    if command -v "${configured[0]}" >/dev/null 2>&1; then
        exec "${configured[@]}" "$@"
    fi
fi

for candidate in firefox brave-origin-stable brave-browser-stable chromium \
                 google-chrome-stable microsoft-edge-stable vivaldi-stable \
                 falkon qutebrowser; do
    if command -v "$candidate" >/dev/null 2>&1; then
        exec "$candidate" "$@"
    fi
done

echo "browser.sh: no web browser found (install firefox or edit this file)" >&2
if command -v notify-send >/dev/null 2>&1; then
    notify-send "Browser" \
        "No web browser found. Install one or edit ~/.config/ml4w/settings/browser.sh"
fi
exit 1
