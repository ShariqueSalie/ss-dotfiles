import Quickshell
import Quickshell.Services.SystemTray
import QtQuick
import Qt5Compat.GraphicalEffects
import QtQuick.Layouts
import qs.CustomTheme

// System tray (StatusNotifierItem hosts).
Rectangle {
    id: tray

    // Draws the chip (the rounded plate behind the icons). Supplied from
    // config.json.
    //
    // Tray icons come from the applications themselves — either as a themed
    // icon name or as a raw pixmap over D-Bus — and their own colours rarely
    // match the bar. A flat colour overlay below paints every icon in exactly
    // the accent used by the other bar buttons. In a light palette the chip is
    // painted in the accent, so the icons switch to the background colour to
    // stay legible on it.
    property bool chip: true

    // Padding between the icon row and the chip edge. Held at the same value in
    // both palettes — the plate is only painted in light mode, but reserving
    // its space in dark mode too keeps the tray (and everything left of it in
    // the right area) from shifting when the theme flips. Kept at 0 when the
    // chip is off so the tray occupies the same space as any other module.
    readonly property real padH: chip ? 8 : 0
    readonly property real padV: chip ? 3 : 0

    // Collapse the slot when there are no tray items, so the right Repeater
    // hides this Loader and the RowLayout doesn't reserve spacing around an
    // empty, zero-width module (which otherwise leaves a doubled gap next to
    // its neighbours).
    readonly property bool collapsed: SystemTray.items.values.length === 0

    // True while any tray context menu is open. The bar pins itself expanded
    // while this is set: the tray lives in the right area, which is only
    // visible/enabled when the pill is expanded, so without this the popup's
    // anchor item would vanish (pointer leaves the bar -> hover lost ->
    // collapse) and the menu would be dismissed the instant it opened.
    property int openMenuCount: 0
    readonly property bool menuOpen: openMenuCount > 0

    // Icons use the bar's accent, except on a light chip where the accent is
    // the chip itself — there they must use the background colour to read.
    readonly property color iconAccent: (chip && Theme.isLight) ? Theme.background : Theme.primary
    readonly property color hoverIconAccent: (chip && Theme.isLight) ? Theme.primary : Theme.background

    implicitWidth: items.implicitWidth + 2 * padH
    implicitHeight: items.implicitHeight + 2 * padV
    radius: height / 2

    // The plate is painted in the highlight color, and only in a light palette:
    // that is the one case where the icons need a dark substrate under them. A
    // dark palette already provides it, so the chip stays out of the way there
    // rather than boxing in icons that read fine as they are.
    color: (chip && Theme.isLight) ? Theme.primary : "transparent"

    Behavior on color {
        ColorAnimation { duration: 200 }
    }

    RowLayout {
        id: items
        anchors.centerIn: parent
        // Tighter than the 14px the bar uses between modules: the chip already
        // separates the tray from its neighbours visually.
        spacing: 8

        Repeater {
            model: SystemTray.items

            delegate: MouseArea {
                id: trayItem
                required property var modelData

                implicitWidth: 20
                implicitHeight: 20
                Layout.alignment: Qt.AlignVCenter
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                acceptedButtons: Qt.LeftButton | Qt.RightButton

                // Same solid accent circle on hover as every other bar button
                // (not a translucent tint, which read as a lighter shade).
                Rectangle {
                    anchors.centerIn: parent
                    width: 30
                    height: 30
                    radius: 15
                    color: trayItem.containsMouse ? tray.iconAccent : "transparent"
                    Behavior on color {
                        ColorAnimation { duration: 500; easing.type: Easing.OutQuint }
                    }
                }

                Image {
                    anchors.centerIn: parent
                    source: trayItem.modelData.icon
                    width: 18
                    height: 18
                    sourceSize.width: 18
                    sourceSize.height: 18
                    fillMode: Image.PreserveAspectFit

                    // Recolor every tray icon — themed or raw pixmap — to the
                    // same shade as the bar's other icons. On hover the icon
                    // flips to the contrast colour over the accent circle.
                    layer.enabled: true
                    layer.effect: ColorOverlay {
                        // A flat overlay (rather than colorization) replaces
                        // the source colour entirely, so the icons land on
                        // exactly the same shade as the SVG bar icons instead
                        // of a lighter tint of their original pixels.
                        color: trayItem.containsMouse
                            ? tray.hoverIconAccent : tray.iconAccent
                        Behavior on color {
                            ColorAnimation { duration: 200 }
                        }
                    }
                }

                onClicked: (mouse) => {
                    // nm-applet (the network/Wi-Fi icon) exposes no Activate
                    // method, only a DBusMenu, so a left click must open the
                    // menu instead of calling activate().
                    const leftOpensMenu = modelData.onlyMenu
                        || modelData.id === "nm-applet"
                    if (mouse.button === Qt.LeftButton && !leftOpensMenu) {
                        modelData.activate()
                    } else if (modelData.hasMenu) {
                        trayMenu.open()
                    }
                }

                QsMenuAnchor {
                    id: trayMenu
                    menu: trayItem.modelData.menu
                    anchor.item: trayItem
                    anchor.edges: Edges.Bottom
                    anchor.gravity: Edges.Bottom

                    // Keep the bar expanded for as long as the menu is open so
                    // the anchor item (and this popup) survive the pointer
                    // leaving the bar surface.
                    onOpened: tray.openMenuCount++
                    onClosed: tray.openMenuCount--
                }
            }
        }
    }
}
