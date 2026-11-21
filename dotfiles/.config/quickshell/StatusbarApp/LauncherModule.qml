import Quickshell
import QtQuick

// Opens the application launcher. Uses the Fedora icon from the local assets.
BarButton {
    iconSrc: "file://" + Quickshell.env("HOME") + "/.config/ml4w/assets/fedora-logo.png"
    colorize: false
    onClicked: {
        Quickshell.execDetached(["bash", "-c",
            Quickshell.env("HOME") + "/.config/ml4w/scripts/ml4w-launcher"])
    }
}
