import Quickshell
import QtQuick

// Initials wordmark -> toggles the Sidebar app via IPC.
BarButton {
    label: "ss."
    onClicked: {
        Quickshell.execDetached(["qs", "ipc", "call", "sidebar", "toggle"])
    }
}
