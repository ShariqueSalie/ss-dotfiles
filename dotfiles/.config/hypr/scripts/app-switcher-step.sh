#!/usr/bin/env bash
# Step the hypr-app-switcher, then commit the selection once the user stops
# tapping. The upstream binds only call "next"/"prev", which opens the HUD and
# previews the target but never moves focus, so ALT+Tab did nothing.
#
# The commit is debounced: every press rewrites the stamp file, and only the
# last press in a burst performs the "release" (commit) call.
set -u

direction="${1:-next}"
switch_dir="$HOME/.local/share/hypr-app-switcher"
stamp_file="${XDG_RUNTIME_DIR:-/tmp}/hypr-app-switcher.stamp"

my_stamp="$$.$RANDOM.$(date +%s%N)"
printf "%s\n" "$my_stamp" >"$stamp_file"

qs -p "$switch_dir" ipc call app-switcher "$direction" >/dev/null 2>&1 || exit 0

# Wait for the burst to settle; a newer press takes over the commit.
sleep 0.35
if [ "$(cat "$stamp_file" 2>/dev/null)" != "$my_stamp" ]; then
    exit 0
fi
qs -p "$switch_dir" ipc call app-switcher release >/dev/null 2>&1 || true
