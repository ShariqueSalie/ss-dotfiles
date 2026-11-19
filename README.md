# S@LI3 OS - Dotfiles for Hyprland

An advanced configuration of Hyprland for Fedora. 

Full featured desktop environment based on the dynamic tiling window manager Hyprland with adaptive material color themes based on the selected wallpaper for all components. Including a comprehensive selection of apps with the ability to customize the configuration to your personal needs.

### Desktop install

Graphical desktop (Fedora):

```sh
curl -fsSL https://raw.githubusercontent.com/ShariqueSalie/dotfiles/main/setup/install-desktop.sh | bash
```

### Server install

Headless server (CLI only: bash aliases, prompt, fastfetch banner, btop,
vim — no Hyprland or quickshell):

```sh
curl -fsSL https://raw.githubusercontent.com/ShariqueSalie/dotfiles/main/setup/install-server.sh | bash
```

The server install is the right choice for a machine without a display.

```sh
# preview without changing anything
curl -fsSL https://raw.githubusercontent.com/ShariqueSalie/dotfiles/main/setup/install-server.sh | bash -s -- --dry-run

# skip the package installation
curl -fsSL https://raw.githubusercontent.com/ShariqueSalie/dotfiles/main/setup/install-server.sh | bash -s -- --no-packages
```

### Login screen

The desktop install also sets up the dwm-s login screen: LightDM with
slick-greeter, the Nord wallpaper, a centred login panel and the MesloLGS
Nerd Font. It defaults to the Hyprland session, disables other display
managers (GDM, SDDM, ...) and enables `lightdm`.

The wallpaper, greeter config and font files are all kept in
`setup/lightdm/` (the same folder as dwm-s), so nothing is downloaded at
login.

```sh
# keep the existing login screen
curl -fsSL https://raw.githubusercontent.com/ShariqueSalie/dotfiles/main/setup/install-desktop.sh | bash -s -- --no-greeter

# or run only the greeter later
bash setup/install-greeter.sh --dry-run
bash setup/install-greeter.sh
```

### Fedora gaming

On Fedora x86_64 the desktop install also mirrors the gaming part of
dwm-s: Steam, Gamescope, GameMode and MangoHud (64- and 32-bit) plus
GameMode tuning access. It enables RPM Fusion nonfree and, before
Fedora 45, the `christitustech/copr-fedora` Gamescope COPR.

Third-party repositories are only enabled after you approve them. When
the installer runs non-interactively, pass the flag:

```sh
curl -fsSL https://raw.githubusercontent.com/ShariqueSalie/dotfiles/main/setup/install-desktop.sh | bash -s -- --enable-fedora-gaming-repos
```

```sh
# skip gaming
curl -fsSL https://raw.githubusercontent.com/ShariqueSalie/dotfiles/main/setup/install-desktop.sh | bash -s -- --no-gaming

# or run it separately
bash setup/install-gaming.sh --dry-run
bash setup/install-gaming.sh --enable-repos
```

## Special Thanks

I want to say thank you to ML4W OS and all other Developers who are creating awesome configurations for our favorite Tiling Window Manager Hyprland. Your support, the testing of every version and all your valuable Pull Requests with improvements and bug fixes have repeatedly improved the overall project and increased its relevance and quality.

Special Thanks do to...

https://github.com/Affanmm for the great and professional ML4W Logo Design and much more.
https://github.com/harilvfs for supporting me in creating the new Wiki https://ml4w.com/os/
https://github.com/dwilliam62 for all your support and testings since the start of the Project
and so many more...

<img width="2560" height="1440" alt="image" src="https://ml4w.com/os/screen-217-2.jpg" />

## Inspirations

The following projects have inspired me:

- https://github.com/JaKooLit/Hyprland-Dots
- https://github.com/prasanthrangan/hyprdots
- https://github.com/sudo-harun/dotfiles
- https://github.com/dianaw353/hyprland-configuration-rootfs
- https://www.youtube.com/@saneAspect

and many more...
