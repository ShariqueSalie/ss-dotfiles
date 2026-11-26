import Quickshell
import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import qs.CustomTheme

// The update badge in the status bar: the dwm-s Update Center icon plus the
// total number of pending updates (packages, Flatpak apps and unpulled GitHub
// commits). Clicking it opens the Update Center card below the bar.
//
// All of the scanning lives in StatusbarWindow (the card needs the same data);
// this module only displays the count and asks the window to toggle the card.
Rectangle {
    id: updates

    // Total number of pending updates across every provider.
    property int count: 0
    // Always visible, like the dwm-s indicator: an up-to-date system still
    // shows the icon (the count is omitted) so the Update Center can be opened.
    readonly property bool collapsed: false
    // Set by the keyboard navigation in StatusbarWindow.
    property bool focused: false

    // Asked the window to open/close the Update Center card.
    signal activateRequested()

    // Run the module's action (mouse click or keyboard Return).
    function activate(): void {
        updates.activateRequested()
    }

    readonly property bool active: mouseArea.containsMouse || updates.focused

    implicitWidth: row.implicitWidth + 8
    implicitHeight: 30
    radius: 15

    // Same accent-filled circle as the other bar buttons on hover/selection.
    color: active ? Theme.primary : "transparent"

    Behavior on color {
        ColorAnimation { duration: 500; easing.type: Easing.OutQuint }
    }

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 4

        // The Update Center icon from dwm-s, tinted with the bar accent like
        // the other modules. On hover it flips to the background colour so it
        // stays legible on the solid accent circle.
        Image {
            Layout.alignment: Qt.AlignVCenter
            source: "assets/update-center/dwm-update-center.png"
            sourceSize.width: 18
            sourceSize.height: 18
            width: 18
            height: 18
            fillMode: Image.PreserveAspectFit
            smooth: true
            layer.enabled: true
            layer.effect: MultiEffect {
                colorization: 1.0
                colorizationColor: updates.active ? Theme.background : Theme.primary

                Behavior on colorizationColor {
                    ColorAnimation { duration: 500; easing.type: Easing.OutQuint }
                }
            }
        }

        Text {
            Layout.alignment: Qt.AlignVCenter
            visible: updates.count > 0
            text: updates.count > 99 ? "99+" : updates.count
            color: updates.active ? Theme.background : Theme.primary
            font.family: Theme.fontFamily
            font.pixelSize: 14
            font.bold: true

            Behavior on color {
                ColorAnimation { duration: 500; easing.type: Easing.OutQuint }
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: updates.activate()
    }
}
