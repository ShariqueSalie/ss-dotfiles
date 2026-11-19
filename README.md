# ML4W OS - Dotfiles for Hyprland

An advanced configuration of Hyprland for Arch Linux based distributions (CachyOS), Fedora, Ubuntu and openSuse Tumbleweed. 

Full featured desktop environment based on the dynamic tiling window manager Hyprland with adaptive material color themes based on the selected wallpaper for all components. Including a comprehensive selection of apps with the ability to customize the configuration to your personal needs.

<img width="2560" height="1440" alt="image" src="https://ml4w.com/os/screen-217.jpg" />

## Installation and Documentation

You can find all installation options in the documentation of the ML4W OS for Hyprland here:<br><b>https://ml4w.com/os/</b>

### Quick Installation

Copy one of the following commands into your terminal:

```sh
bash <(curl -s https://ml4w.com/os/stable) # Stable Release
```

```sh
bash <(curl -s https://ml4w.com/os/rolling) # Rolling Release
```
Arch, Fedora, Ubuntu and openSuse Tumbleweed are directly supported.

### Install this fork

This fork adds personal customizations on top of ML4W (ss. branding, the
dwm-s status bar, the ss. fastfetch banner and more). The upstream quick
commands above clone `mylinuxforwork/dotfiles`, so they do **not** include
these changes.

Graphical desktop (Fedora, Arch, Ubuntu, openSUSE Tumbleweed):

```sh
curl -fsSL https://raw.githubusercontent.com/ShariqueSalie/dotfiles/main/setup/install-desktop.sh | bash
```

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

### Test and install with the ML4W OS Live ISO

Test the ML4W OS without risk on your computer or in a Virtual Machine with the ML4W Live ISO.

<a href="https://ml4w.com/iso/ml4w-os/ml4w-os-2.17-x86_64.iso">Download the ML4W ISO</a>

You can install the ML4W OS on your hard drive with the command `sudo install-ml4w-os` (BETA).

## Special Thanks

I want to say thank you to all contributors of the ML4W OS and all other Developers who are creating awesome configurations for our favorite Tiling Window Manager Hyprland. Your support, the testing of every version and all your valuable Pull Requests with improvements and bug fixes have repeatedly improved the overall project and increased its relevance and quality.

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
