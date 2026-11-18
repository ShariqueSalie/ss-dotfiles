import Quickshell
import QtQuick

// Opens the application launcher. It wears the dwm-s "S" logo, drawn as the
// Nerd Font glyph from that desktop's bar instead of an SVG.
BarButton {
    glyph: "󰰣"
    onClicked: {
        Quickshell.execDetached(["bash", "-c",
            Quickshell.env("HOME") + "/.config/ml4w/scripts/ml4w-launcher"])
    }
}
