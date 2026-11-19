#!/bin/bash
# Open the given files in the first available editor.
#
# The Welcome screen calls this script without a terminal, so try GUI editors
# first. If none is installed, fall back to $EDITOR (or a terminal editor) and
# run it inside kitty.

for editor in gnome-text-editor kate code codium gedit; do
    if command -v "$editor" >/dev/null 2>&1; then
        exec "$editor" "$@"
    fi
done

editor=${EDITOR:-}
if [[ -z $editor ]] || ! command -v "$editor" >/dev/null 2>&1; then
    for candidate in micro nano vim vi; do
        if command -v "$candidate" >/dev/null 2>&1; then
            editor=$candidate
            break
        fi
    done
fi

if [[ -n $editor ]]; then
    if command -v kitty >/dev/null 2>&1; then
        exec kitty --class dotfiles-floating -e "$editor" "$@"
    fi
    exec "$editor" "$@"
fi

echo "No editor found. Install one, e.g. gnome-text-editor." >&2
exit 1
