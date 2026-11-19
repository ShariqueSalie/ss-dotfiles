//@ pragma UseQApplication

import Quickshell
import Quickshell.Io
import "WelcomeApp"
import "SidebarApp"
import "WallpaperApp"
import "StatusbarApp"
import "CustomTheme"

ShellRoot {
    // Test IPC tools: qs ipc show

    IpcHandler {
        target: "theme-manager" 
        function reload(): void {
            Theme.reloadTheme()
        }
    }

    WelcomeWindow {}
    SidebarWindow {}
    WallpaperWindow {}
    WallpaperCarousel {}
    // One status bar per connected monitor.
    Variants {
        model: Quickshell.screens
        StatusbarWindow {
            property var modelData
            screen: modelData
            primaryBar: modelData.name === "eDP-1"
        }
    }
}