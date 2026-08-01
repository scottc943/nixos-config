# NixOS Configuration

My personal declarative NixOS configuration using Nix flakes and Home Manager.

The configuration is currently being developed and tested in a NixOS virtual machine before migrating my physical desktop from Arch Linux to NixOS.

## Features

- NixOS flakes
- Home Manager
- Mango Wayland compositor
- Waybar
- Rofi
- Dunst notifications
- Firefox and Chromium
- Visual Studio Code
- Neovim with LazyVim
- JetBrains development tools
- Declaratively managed Flatpaks
- Gear Lever and AppImage support
- Separate VM and physical desktop configuration
- Steam and GameMode configuration for the physical desktop

## Repository Structure

```text
.
├── assets/                 # Wallpapers and other configuration assets
├── home/scott/             # Home Manager configuration
├── hosts/                  # Host-specific NixOS configurations
├── modules/home/           # Shared Home Manager modules
├── modules/nixos/          # Shared NixOS modules
├── flake.nix
└── flake.lock
```
