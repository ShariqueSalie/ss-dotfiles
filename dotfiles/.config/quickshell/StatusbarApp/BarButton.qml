import QtQuick
import QtQuick.Effects
import qs.CustomTheme

// Reusable round icon button used across the status bar modules.
Rectangle {
    id: btn
    property string iconSrc: ""
    property bool colorize: true
    // Optional Nerd Font glyph shown instead of `iconSrc`. Used for the dwm-s
    // "S" logo, which only exists as a Private Use Area character in the
    // Meslo Nerd Font (Fira Sans has no glyph for it).
    property string glyph: ""
    property int glyphSize: 20
    // Set by the keyboard navigation in StatusbarWindow to highlight the
    // currently selected module.
    property bool focused: false
    signal clicked()

    // Run the button's action (mouse click or keyboard Return).
    function activate(): void { btn.clicked() }

    // Highlighted when hovered with the mouse or selected via the keyboard.
    readonly property bool active: mouseArea.containsMouse || btn.focused

    implicitWidth: 30
    implicitHeight: 30
    radius: 15

    // Every button gets the same accent-filled circle on hover/selection.
    // (colorize only controls whether the icon itself is recolored, so the
    // ML4W logo keeps its own colors while still matching the others.)
    color: btn.active ? Theme.primary : "transparent"

    // Fade the accent circle in on hover/selection and out again on leave.
    Behavior on color {
        ColorAnimation { duration: 500; easing.type: Easing.OutQuint }
    }

    Image {
        anchors.centerIn: parent
        visible: btn.glyph === ""
        source: btn.iconSrc
        width: 18
        height: 18
        sourceSize.width: 18
        sourceSize.height: 18
        fillMode: Image.PreserveAspectFit
        layer.enabled: btn.colorize
        layer.effect: MultiEffect {
            colorization: 1.0
            colorizationColor: btn.active ? Theme.background : Theme.primary

            // Recolor the icon in step with the circle fade.
            Behavior on colorizationColor {
                ColorAnimation { duration: 500; easing.type: Easing.OutQuint }
            }
        }
    }

    Text {
        anchors.centerIn: parent
        visible: btn.glyph !== ""
        text: btn.glyph
        color: btn.active ? Theme.background : Theme.primary
        font.family: Theme.iconFontFamily
        font.pixelSize: btn.glyphSize

        Behavior on color {
            ColorAnimation { duration: 500; easing.type: Easing.OutQuint }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: btn.clicked()
    }
}
