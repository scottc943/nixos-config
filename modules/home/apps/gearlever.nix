{ pkgs, ... }:

let
  gearlever = pkgs.writeShellApplication {
    name = "gearlever";

    runtimeInputs = [
      pkgs.flatpak
    ];

    text = ''
      exec flatpak run it.mijorus.gearlever "$@"
    '';
  };
in
{
  home.packages = [
    gearlever
  ];

  # Gear Lever permissions.
  #
  # This file is deliberately managed by Home Manager at the USER
  # override level. This prevents Flatseal/user overrides from silently
  # removing permissions that Gear Lever requires.
  #
  # These mirror Gear Lever's upstream Flatpak permissions.
  xdg.dataFile."flatpak/overrides/it.mijorus.gearlever" = {
    force = true;

    text = ''
      [Context]
      shared=network;ipc;
      sockets=wayland;fallback-x11;
      devices=dri;
      filesystems=host;/tmp;

      [Session Bus Policy]
      org.freedesktop.Flatpak=talk
    '';
  };

  # Periodically refresh AppImage update information.
  #
  # This checks for available updates and allows Gear Lever to issue
  # notifications. Actual replacement of an AppImage remains under
  # Gear Lever's normal update workflow.
  systemd.user.services.gearlever-fetch-updates = {
    Unit = {
      Description = "Check Gear Lever AppImages for updates";
      After = [ "graphical-session.target" ];
    };

    Service = {
      Type = "oneshot";
      ExecStart =
        "${gearlever}/bin/gearlever --fetch-updates";
    };
  };

  systemd.user.timers.gearlever-fetch-updates = {
    Unit = {
      Description = "Periodically check Gear Lever AppImages for updates";
    };

    Timer = {
      OnBootSec = "10m";
      OnUnitActiveSec = "12h";
      Unit = "gearlever-fetch-updates.service";
    };

    Install = {
      WantedBy = [ "timers.target" ];
    };
  };
}
