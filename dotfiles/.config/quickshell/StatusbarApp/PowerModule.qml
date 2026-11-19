import Quickshell
import QtQuick

// Power menu -> toggles the ML4W Power Menu (github.com/mylinuxforwork/ml4w-powermenu).
// Goes through ml4w-power-menu so the button also works when the menu's
// quickshell process is not running.
BarButton {
    iconSrc: "../shared/icons/power.svg"
    onClicked: {
        Quickshell.execDetached(["bash", "-c",
            Quickshell.env("HOME") + "/.config/ml4w/scripts/ml4w-power-menu"])
    }
}
