import Quickshell
import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import qs.CustomTheme

// The Update Center card, ported from the dwm-s desktop and drawn inside the
// status bar's own window (like the calendar and the audio output dropdown, so
// it receives clicks under the layer-shell input mask).
//
// It lists one row per provider from ml4w-update-center: the system package
// manager, Flatpak and the dotfiles' GitHub branch. Each row expands to show
// the individual packages/commits and can launch that provider's update.
Item {
    id: panel

    // Open/closed, driven by the bar module and the "updates" IPC handler.
    property bool isOpen: false
    // Where the card sits when open, in window coordinates (set by the parent).
    property real openY: 0
    // Keeps the item rendered until the closing slide has finished.
    property bool showPanel: false

    // Snapshot from StatusbarWindow.
    property var providers: []
    // Make the dnf maintenance buttons (below the provider rows) available
    // only when the system provider is the Fedora one.
    readonly property bool dnfAvailable: {
        for (let i = 0; i < panel.providers.length; i++)
            if (panel.providers[i].id === "system")
                return panel.providers[i].name === "Fedora packages"
        return false
    }
    property bool scanning: false
    property string error: ""
    property double checked: 0

    // Local UI state.
    property double now: Date.now() / 1000
    property var expandedIds: ({})
    property int cardInset: 20

    implicitWidth: 430
    // Fit the card to its content (a handful of provider rows) and only grow
    // to the available height when the lists are long, at which point the
    // provider list starts scrolling.
    readonly property int maximumHeight: panel.parent
        ? Math.max(200, Math.round(panel.parent.height - openY - 20))
        : 520
    readonly property int contentHeight: cardColumn.implicitHeight + 2 * cardInset + 2 * 18
    implicitHeight: Math.min(maximumHeight, Math.max(160, contentHeight))
    width: implicitWidth
    height: implicitHeight
    visible: showPanel
    z: 100

    // Parked above the window (and so off-screen) when closed.
    readonly property real hiddenY: -height - 20
    y: isOpen ? openY : hiddenY

    signal refreshRequested()
    signal actionRequested(string providerId)
    signal closeRequested()

    Behavior on y {
        NumberAnimation {
            duration: 320
            easing.type: Easing.OutQuint
            onRunningChanged: {
                if (!running && !panel.isOpen)
                    panel.showPanel = false
            }
        }
    }

    onIsOpenChanged: if (isOpen) showPanel = true

    Timer {
        interval: 30000
        repeat: true
        running: panel.visible
        onTriggered: panel.now = Date.now() / 1000
    }

    function totalCount(): int {
        let total = 0
        for (let i = 0; i < panel.providers.length; i++)
            total += Number(panel.providers[i].count) || 0
        return total
    }

    function checkedLabel(): string {
        if (panel.checked <= 0)
            return "Not checked yet"
        let seconds = Math.max(0, Math.floor(panel.now - panel.checked))
        if (seconds < 60)
            return "Checked just now"
        if (seconds < 3600)
            return "Checked " + Math.floor(seconds / 60) + "m ago"
        if (seconds < 86400)
            return "Checked " + Math.floor(seconds / 3600) + "h ago"
        return "Checked " + Math.floor(seconds / 86400) + "d ago"
    }

    function summary(): string {
        if (panel.scanning)
            return "Checking for updates..."
        let total = panel.totalCount()
        let state = total > 0 ? total + (total === 1 ? " update available" : " updates available")
                              : "Everything is up to date"
        return state + "  ·  " + panel.checkedLabel()
    }

    function isExpanded(identifier): bool {
        return panel.expandedIds[identifier] === true
    }

    function toggleExpanded(identifier): void {
        let next = {}
        for (let key in panel.expandedIds)
            next[key] = panel.expandedIds[key]
        next[identifier] = !next[identifier]
        panel.expandedIds = next
    }

    function statusColor(prov): color {
        if (prov.status === "error" || prov.status === "offline")
            return Theme.error
        if (prov.status === "updates")
            return Theme.primary
        return Theme.on_surface_variant
    }

    function itemLines(prov): string {
        let items = prov.items || []
        let lines = []
        for (let i = 0; i < items.length && i < 12; i++) {
            let item = items[i]
            let line = item.name || ""
            if (item.from && item.to)
                line += "  (" + item.from + " → " + item.to + ")"
            else if (item.to)
                line += "  →  " + item.to
            lines.push(line)
        }
        if (items.length > 12)
            lines.push("+ " + (items.length - 12) + " more")
        return lines.join("\n")
    }

    // Small bordered text button, matching the calendar's ML4WButton.
    component MiniButton: Rectangle {
        id: control

        property string label: ""
        property bool primary: false

        signal clicked()

        implicitWidth: controlText.implicitWidth + 18
        implicitHeight: 24
        radius: 6
        color: control.primary ? Theme.primary
            : (controlMouse.containsMouse
                ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.20)
                : "transparent")
        opacity: controlMouse.containsMouse && control.primary ? 0.85 : 1
        border.width: control.primary ? 0 : 1
        border.color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.5)

        Text {
            id: controlText
            anchors.centerIn: parent
            text: control.label
            color: control.primary ? Theme.background : Theme.primary
            font.family: Theme.fontFamily
            font.pixelSize: 11
            font.bold: true
        }

        MouseArea {
            id: controlMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: control.clicked()
        }
    }

    // Swallow clicks on the card's padding so they don't reach the
    // window-wide dismiss area behind it.
    MouseArea {
        anchors.fill: parent
        anchors.margins: panel.cardInset
        acceptedButtons: Qt.LeftButton | Qt.RightButton
    }

    Item {
        anchors.fill: parent
        anchors.margins: panel.cardInset

        PanelBackground {
            id: cardBackground
            anchors.fill: parent
            radius: 10
            borderWidth: 2
            fillOpacity: Theme.surfaceOpacity(0.95)
        }

        ColumnLayout {
            id: cardColumn
            anchors.fill: parent
            anchors.margins: 18
            spacing: 10

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Image {
                    Layout.alignment: Qt.AlignVCenter
                    source: "assets/update-center/dwm-update-center.png"
                    sourceSize.width: 24
                    sourceSize.height: 24
                    width: 24
                    height: 24
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                }

                Text {
                    Layout.fillWidth: true
                    text: "Update Center"
                    color: Theme.primary
                    font.family: Theme.fontFamily
                    font.pixelSize: 16
                    font.bold: true
                }

                MiniButton {
                    label: "Refresh"
                    onClicked: panel.refreshRequested()
                }

                MiniButton {
                    label: "Close"
                    onClicked: panel.closeRequested()
                }
            }

            Text {
                Layout.fillWidth: true
                text: panel.summary()
                color: Theme.on_surface_variant
                font.family: Theme.fontFamily
                font.pixelSize: 11
                elide: Text.ElideRight
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 1
                color: Theme.primary
                opacity: 0.25
            }

            Text {
                Layout.fillWidth: true
                visible: panel.error.length > 0
                text: panel.error
                color: Theme.error
                font.family: Theme.fontFamily
                font.pixelSize: 11
                wrapMode: Text.Wrap
            }

            Flickable {
                id: providerViewport

                Layout.fillWidth: true
                Layout.preferredHeight: Math.min(providerColumn.implicitHeight, 300)
                Layout.minimumHeight: 0
                clip: true
                contentWidth: width
                contentHeight: providerColumn.implicitHeight
                boundsBehavior: Flickable.StopAtBounds
                flickableDirection: Flickable.VerticalFlick

                ColumnLayout {
                    id: providerColumn
                    width: providerViewport.width
                    spacing: 8

                    Repeater {
                        model: panel.providers

                        Rectangle {
                            id: providerRow

                            required property var modelData
                            readonly property var prov: modelData
                            readonly property bool open: panel.isExpanded(prov.id)

                            Layout.fillWidth: true
                            implicitHeight: rowColumn.implicitHeight + 22
                            radius: 9
                            color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.07)
                            border.width: 1
                            border.color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.22)

                            ColumnLayout {
                                id: rowColumn

                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.top: parent.top
                                anchors.margins: 11
                                spacing: 7

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 10

                                    Image {
                                        Layout.alignment: Qt.AlignVCenter
                                        source: "assets/update-center/" + providerRow.prov.icon
                                        sourceSize.width: 18
                                        sourceSize.height: 18
                                        width: 18
                                        height: 18
                                        fillMode: Image.PreserveAspectFit
                                        layer.enabled: true
                                        layer.effect: MultiEffect {
                                            colorization: 1.0
                                            colorizationColor: Theme.primary
                                        }
                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 1

                                        Text {
                                            Layout.fillWidth: true
                                            text: providerRow.prov.name
                                            color: Theme.on_background
                                            font.family: Theme.fontFamily
                                            font.pixelSize: 13
                                            font.bold: true
                                            elide: Text.ElideRight
                                        }

                                        Text {
                                            Layout.fillWidth: true
                                            text: providerRow.prov.headline
                                            color: panel.statusColor(providerRow.prov)
                                            font.family: Theme.fontFamily
                                            font.pixelSize: 11
                                            elide: Text.ElideRight
                                        }
                                    }

                                    Rectangle {
                                        visible: providerRow.prov.count > 0
                                        implicitWidth: countLabel.implicitWidth + 12
                                        implicitHeight: 20
                                        radius: 10
                                        color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.18)

                                        Text {
                                            id: countLabel
                                            anchors.centerIn: parent
                                            text: providerRow.prov.count
                                            color: Theme.primary
                                            font.family: Theme.fontFamily
                                            font.pixelSize: 11
                                            font.bold: true
                                        }
                                    }

                                    MiniButton {
                                        visible: providerRow.prov.updateAvailable === true
                                        label: providerRow.prov.actionLabel || "Update"
                                        primary: true
                                        onClicked: panel.actionRequested(providerRow.prov.id)
                                    }

                                    MiniButton {
                                        visible: (providerRow.prov.items && providerRow.prov.items.length > 0)
                                            || (providerRow.prov.detail || "").length > 0
                                        label: providerRow.open ? "Hide" : "Details"
                                        onClicked: panel.toggleExpanded(providerRow.prov.id)
                                    }
                                }

                                Text {
                                    Layout.fillWidth: true
                                    visible: providerRow.open && (providerRow.prov.detail || "").length > 0
                                    text: providerRow.prov.detail || ""
                                    color: Theme.on_surface_variant
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 11
                                    wrapMode: Text.Wrap
                                }

                                Text {
                                    Layout.fillWidth: true
                                    visible: providerRow.open
                                        && providerRow.prov.items
                                        && providerRow.prov.items.length > 0
                                    text: panel.itemLines(providerRow.prov)
                                    color: Theme.on_background
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 11
                                    lineHeight: 1.25
                                    wrapMode: Text.Wrap
                                }
                            }
                        }
                    }
                }
            }

            // Fedora maintenance, below the provider rows (Dotfiles is last).
            // Both run in a terminal: dnf asks for its own confirmation and
            // sudo needs a TTY.
            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                visible: panel.dnfAvailable

                MiniButton {
                    Layout.fillWidth: true
                    label: "Distro Sync"
                    onClicked: panel.actionRequested("dnf-distro-sync")
                }

                MiniButton {
                    Layout.fillWidth: true
                    label: "Upgrade (Refresh)"
                    onClicked: panel.actionRequested("dnf-upgrade-refresh")
                }
            }
        }
    }
}
