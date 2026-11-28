# S@LI3 OS - Dotfiles for Hyprland

An advanced configuration of Hyprland for Fedora. 

Full featured desktop environment based on the dynamic tiling window manager Hyprland with adaptive material color themes based on the selected wallpaper for all components. Including a comprehensive selection of apps with the ability to customize the configuration to your personal needs.
Use this for a headless server


```sh
curl -fsSL https://raw.githubusercontent.com/ShariqueSalie/ss-dotfiles/main/setup/install-server.sh | bash
```

### Desktop install

Graphical desktop (Fedora):

On Fedora x86_64 the desktop install also mirrors the gaming part of
dwm-s: Steam, Gamescope, GameMode and MangoHud (64- and 32-bit) plus
GameMode tuning access. It enables RPM Fusion nonfree and, before
Fedora 45, the `christitustech/copr-fedora` Gamescope COPR.

Third-party repositories are only enabled after you approve them. When
the installer runs non-interactively, pass the flag:

```sh
curl -fsSL https://raw.githubusercontent.com/ShariqueSalie/ss-dotfiles/main/setup/install-desktop.sh | bash -s -- --enable-fedora-gaming-repos
```



## Special Thanks

I want to say thank you to ML4W OS and all other Developers who are creating awesome configurations for our favorite Tiling Window Manager Hyprland.

