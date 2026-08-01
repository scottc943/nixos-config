{ pkgs, ... }:
{
  home.packages = with pkgs; [
    bruno
    dbeaver-bin
    discord
    kdePackages.ark
    kdePackages.dolphin
    libreoffice-fresh
    obs-studio
    pavucontrol
    prismlauncher
    virt-manager
    vlc
  ];
}
