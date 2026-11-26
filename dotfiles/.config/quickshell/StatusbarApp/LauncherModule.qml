import Quickshell
import QtQuick

// Opens the application launcher. Uses the same Fedora icon as the Fedora
// packages row in Update Center.
BarButton {
    iconSrc: "file://" + Quickshell.env("HOME") + "/.config/quickshell/StatusbarApp/assets/update-center/fedora.svg"
    onClicked: {
        Quickshell.execDetached(["bash", "-c",
            Quickshell.env("HOME") + "/.config/ml4w/scripts/ml4w-launcher"])
    }
}
