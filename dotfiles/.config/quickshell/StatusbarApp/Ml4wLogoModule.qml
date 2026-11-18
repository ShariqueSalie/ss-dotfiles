import Quickshell
import QtQuick

// Filled "ss." mark -> toggles the Sidebar app via IPC. The badge keeps the
// shape of the ML4W logo tile it replaces.
BarButton {
    label: "ss."
    labelSize: 13
    badge: true
    onClicked: {
        Quickshell.execDetached(["qs", "ipc", "call", "sidebar", "toggle"])
    }
}
