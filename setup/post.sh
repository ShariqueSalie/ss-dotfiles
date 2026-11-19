#!/usr/bin/env bash

# --------------------------------------------------------------
# Oh My Posh
# --------------------------------------------------------------

curl -s https://ohmyposh.dev/install.sh | bash -s -- -d ~/.local/bin

# --------------------------------------------------------------
# ML4W Settings App
# --------------------------------------------------------------

bash <(curl -s https://raw.githubusercontent.com/mylinuxforwork/ml4w-dotfiles-settings/main/setup.sh)

# --------------------------------------------------------------
# Quickshell Overview
# --------------------------------------------------------------

bash <(curl -s https://raw.githubusercontent.com/mylinuxforwork/ml4w-quickshell-overview/main/install.sh)

# --------------------------------------------------------------
# Hypr App Switcher
# --------------------------------------------------------------

bash <(curl -s https://raw.githubusercontent.com/anshifmonz/hypr-app-switcher/main/install.sh)

# --------------------------------------------------------------
# ML4W Dock
# --------------------------------------------------------------

bash <(curl -s https://raw.githubusercontent.com/mylinuxforwork/ml4w-dock/main/install.sh)

# --------------------------------------------------------------
# ML4W Power Menu
# --------------------------------------------------------------

bash <(curl -s https://raw.githubusercontent.com/mylinuxforwork/ml4w-powermenu/main/install.sh)

# --------------------------------------------------------------
# ML4W Walker (app launcher + its provider daemon, elephant)
# --------------------------------------------------------------

bash <(curl -s https://raw.githubusercontent.com/mylinuxforwork/ml4w-walker/main/install.sh)
ml4w-walker add clipboard

# --------------------------------------------------------------
# Cursors
# --------------------------------------------------------------

source $repo_path/setup/_cursors.sh

# --------------------------------------------------------------
# Fonts
# --------------------------------------------------------------

source $repo_path/setup/_fonts.sh

# --------------------------------------------------------------
# Icons
# --------------------------------------------------------------

source $repo_path/setup/_icons.sh

# --------------------------------------------------------------
# Power button
# --------------------------------------------------------------

source $repo_path/setup/_powerkey.sh

# --------------------------------------------------------------
# Networking and Bluetooth
# --------------------------------------------------------------

# The desktop menu and the bar use NetworkManager and BlueZ. Installing the
# packages is not enough on distributions that do not enable these services
# by default (Arch, for example), so turn them on here.
if command -v nmcli >/dev/null 2>&1; then
    sudo systemctl enable --now NetworkManager.service 2>/dev/null ||
        echo "warning: could not enable NetworkManager.service" >&2
fi
if command -v bluetoothctl >/dev/null 2>&1; then
    sudo systemctl enable --now bluetooth.service 2>/dev/null ||
        echo "warning: could not enable bluetooth.service" >&2
fi

# --------------------------------------------------------------
# Create XDG Directories
# --------------------------------------------------------------

xdg-user-dirs-update

# --------------------------------------------------------------
# Login screen (dwm-s LightDM + slick-greeter)
# --------------------------------------------------------------

if [[ "${ML4W_NO_GREETER:-0}" != "1" ]]; then
    bash "$repo_path/setup/install-greeter.sh" ||
        echo "warning: the LightDM greeter install failed; the desktop is still installed" >&2
fi