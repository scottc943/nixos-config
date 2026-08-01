{ ... }:
{
  # Installs appimage-run and registers AppImage files with binfmt so they
  # can be launched directly by Gear Lever or from the shell.
  programs.appimage = {
    enable = true;
    binfmt = true;
  };
}
