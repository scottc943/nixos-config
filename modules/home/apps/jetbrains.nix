{ pkgs, ... }:
{
  home.packages = [
    pkgs.jetbrains.clion
    pkgs.jetbrains.idea
    pkgs.jetbrains.pycharm
    pkgs.jetbrains.rider
    pkgs.jetbrains."rust-rover"
  ];
}
