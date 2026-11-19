#!/usr/bin/env bash
# Add copr repositories

# Hyprland Packages
sudo dnf copr enable --assumeyes lionheartp/Hyprland
# sudo dnf copr enable --assumeyes mineiro/hyprland
# sudo dnf copr enable --assumeyes sdegler/hyprland

# Bibata Cursor Themes
sudo dnf copr enable --assumeyes peterwu/rendezvous

# Cliphist
# sudo dnf copr enable --assumeyes wef/cliphist

# nwg displays and nwg-look
sudo dnf copr enable --assumeyes tofik/nwg-shell

# Nerd Fonts
sudo dnf copr enable --assumeyes che/nerd-fonts

# SwayNC
sudo dnf copr enable --assumeyes erikreider/SwayNotificationCenter

# Quickshell
# sudo dnf copr enable --assumeyes errornointernet/quickshell

# --------------------------------------------------------------
# Brave Origin (the default web browser)
# --------------------------------------------------------------

# setup/packages/packages-fedora installs brave-origin from Brave's own RPM
# repository. Writing the .repo file keeps this working on dnf4 and dnf5
# without needing dnf-plugins-core.
if [ ! -f /etc/yum.repos.d/brave-browser.repo ]; then
    info "Adding the Brave Origin RPM repository"
    sudo curl -fsSL --retry 3 --retry-delay 2 \
        -o /etc/yum.repos.d/brave-browser.repo \
        https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo ||
        echo "warning: could not add the Brave repository" >&2
fi
sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc 2>/dev/null ||
    echo "warning: could not import the Brave signing key" >&2

# --------------------------------------------------------------
# Uninstall swww if exists. To be replaced with awww in the next steps
# --------------------------------------------------------------

if command -v swww &> /dev/null || dnf list installed swww &> /dev/null; then
    sudo dnf remove -y swww
fi