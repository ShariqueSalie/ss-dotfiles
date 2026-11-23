#!/usr/bin/env bash
# Open the Emote picker. Emote stays resident after its first launch, so a
# plain `flatpak run` does nothing on later shortcuts: launch it if needed,
# then ask the running instance to activate its picker over D-Bus.
set -u

BUS=com.tomjwatson.Emote
PATH_OBJ=/com/tomjwatson/Emote

emote_running() {
    busctl --user --no-pager list 2>/dev/null | grep -q "[[:space:]]$BUS[[:space:]]"
}

if ! emote_running; then
    setsid flatpak run "$BUS" >/dev/null 2>&1 </dev/null &
    for _ in $(seq 1 50); do
        emote_running && break
        sleep 0.1
    done
fi

busctl --user call "$BUS" "$PATH_OBJ" org.freedesktop.Application Activate a{sv} 0 >/dev/null 2>&1
