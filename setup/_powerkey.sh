#!/usr/bin/env bash

# --------------------------------------------------------------
# Power button
# --------------------------------------------------------------

# Hyprland opens the ML4W power menu on XF86PowerOff. Tell systemd-logind not
# to shut the machine down on the same key press (long press included).
echo "[INFO] Configuring the power button to open the power menu..."
sudo mkdir -p /etc/systemd/logind.conf.d
printf '[Login]\nHandlePowerKey=ignore\nHandlePowerKeyLongPress=ignore\n' \
    | sudo tee /etc/systemd/logind.conf.d/10-powerkey.conf >/dev/null
sudo systemctl kill -s HUP systemd-logind
