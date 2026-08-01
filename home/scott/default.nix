{ pkgs, ... }:
{
  imports = [
    ../../modules/home/mango
    ../../modules/home/apps
    ../../modules/home/editors/lazyvim
  ];

  home = {
    username = "scott";
    homeDirectory = "/home/scott";
    stateVersion = "26.05";

    sessionVariables = {
      NIXOS_OZONE_WL = "1";
    };

    packages = with pkgs; [
      ghostty
      kitty
      wlogout
    ];
  };

  programs = {
    home-manager.enable = true;
    git.enable = true;
    zsh.enable = true;
  };

  xdg = {
    enable = true;
    userDirs.enable = true;
    userDirs.createDirectories = true;
  };
}
