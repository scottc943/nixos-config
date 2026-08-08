{
  lib,
  pkgs,
  ...
}:

let
  runeliteExecutable = lib.getExe pkgs.runelite;

  runeliteShim = pkgs.writeShellScript "jagex-runelite-shim" ''
    #!/usr/bin/env bash

    # NIXOS_JAGEX_RUNELITE_SHIM
    #
    # Jagex launches this file with its JX_* environment variables
    # already exported. exec preserves that environment and forwards
    # all command-line arguments to native RuneLite.

    exec ${runeliteExecutable} "$@"
  '';

  applyRuneliteShim = pkgs.writeShellApplication {
    name = "apply-jagex-runelite-shim";

    runtimeInputs = [
      pkgs.coreutils
      pkgs.gnugrep
    ];

    text = ''
      set -euo pipefail

      runelite_dir="$HOME/.local/share/Jagex Launcher/games/runelite"

      target="$runelite_dir/RuneLite.AppImage"

      backup="$runelite_dir/RuneLite.AppImage.jagex-original"

      # Jagex has not installed RuneLite yet.
      if [[ ! -e "$target" ]]; then
        exit 0
      fi

      # If our shim is already installed, there is nothing to do.
      if head -c 2048 "$target" 2>/dev/null |
        grep -a -q 'NIXOS_JAGEX_RUNELITE_SHIM'
      then
        exit 0
      fi

      echo "Jagex RuneLite AppImage detected."

      # Preserve the most recently downloaded Jagex RuneLite AppImage.
      cp -f -- "$target" "$backup"

      # Install a normal writable copy of the shim rather than a symlink
      # into /nix/store. This allows Jagex to replace the file when it
      # downloads another RuneLite update.
      install \
        -m 0755 \
        ${runeliteShim} \
        "$target"

      echo "Installed native NixOS RuneLite shim."
    '';
  };
in
{
  home.packages = [
    pkgs.runelite
    applyRuneliteShim
  ];

  # Check once whenever Scott's user session starts.
  systemd.user.services.jagex-runelite-shim = {
    Unit = {
      Description = "Install native RuneLite shim for Jagex Launcher";
    };

    Service = {
      Type = "oneshot";

      ExecStart =
        "${applyRuneliteShim}/bin/apply-jagex-runelite-shim";
    };

    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  # Jagex can replace RuneLite.AppImage when it updates RuneLite.
  # Watch that directory and put our shim back whenever it changes.
  systemd.user.paths.jagex-runelite-shim = {
    Unit = {
      Description = "Watch Jagex RuneLite AppImage for replacement";
    };

    Path = {
      PathChanged =
        "%h/.local/share/Jagex Launcher/games/runelite";

      Unit = "jagex-runelite-shim.service";
    };

    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
