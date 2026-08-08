{ pkgs, ... }:

let
  # Convenient host command:
  #
  #   gearlever
  #
  # instead of:
  #
  #   flatpak run it.mijorus.gearlever
  gearlever = pkgs.writeShellApplication {
    name = "gearlever";

    runtimeInputs = [
      pkgs.flatpak
    ];

    text = ''
      exec flatpak run it.mijorus.gearlever "$@"
    '';
  };

  # Configure update sources that Gear Lever can manage natively.
  #
  # Jagex publishes a stable URL that always points at the latest
  # x86_64 Linux AppImage, which is a perfect match for Gear Lever's
  # StaticFileUpdater.
  configureGearleverUpdaters = pkgs.writeShellApplication {
    name = "configure-gearlever-updaters";

    runtimeInputs = [
      pkgs.flatpak
    ];

    text = ''
      set -euo pipefail

      jagex_app="$HOME/AppImages/jagex_launcher.appimage"

      jagex_url="https://rs-launcher-updates.runescape.com/production/linux/x64/latest/jagex-launcher-beta-linux-x86_64.AppImage"

      if [[ -f "$jagex_app" ]]; then
        echo "Configuring Jagex Launcher update source..."

        flatpak run \
          it.mijorus.gearlever \
          --set-update-source \
          "$jagex_app" \
          --manager StaticFileUpdater \
          "url=$jagex_url"

        echo "Jagex Launcher update source configured."
      else
        echo "Jagex Launcher is not currently installed:"
        echo "  $jagex_app"
      fi
    '';
  };

  # Lighthouse stable releases are ZIP archives containing:
  #
  #   lighthouse.appimage
  #   gamecontrollerdb.txt
  #   readme.txt
  #
  # Gear Lever cannot directly use the ZIP as an AppImage update
  # source, so this helper:
  #
  #   1. Queries the latest stable GitHub release.
  #   2. Finds the *-Linux.zip asset.
  #   3. Compares its release tag with Gear Lever's installed version.
  #   4. Downloads and extracts the archive.
  #   5. Hands lighthouse.appimage back to Gear Lever using
  #      --integrate --replace.
  #   6. Refreshes the controller database shipped with Lighthouse.
  #
  # Run:
  #
  #   lighthouse-update --check
  #
  # to check without changing anything.
  #
  # Run:
  #
  #   lighthouse-update
  #
  # to install an available update.
  lighthouseUpdate = pkgs.writeShellApplication {
    name = "lighthouse-update";

    runtimeInputs = [
      pkgs.coreutils
      pkgs.curl
      pkgs.findutils
      pkgs.flatpak
      pkgs.gnused
      pkgs.jq
      pkgs.libnotify
      pkgs.unzip
    ];

    text = ''
      set -euo pipefail

      mode="update"

      if [[ $# -gt 0 ]]; then
        mode="$1"
      fi

      if [[ "$mode" != "update" && "$mode" != "--check" ]]; then
        echo "Usage:"
        echo "  lighthouse-update"
        echo "  lighthouse-update --check"
        exit 2
      fi

      app="$HOME/AppImages/lighthouse.appimage"

      if [[ ! -f "$app" ]]; then
        echo "Lighthouse is not installed at:"
        echo "  $app"
        exit 1
      fi

      echo "Reading installed Lighthouse version..."

      installed_json="$(
        flatpak run \
          it.mijorus.gearlever \
          --list-installed \
          --json
      )"

      current_version="$(
        printf '%s' "$installed_json" |
          jq -r \
            --arg path "$app" \
            '
              .installed[]
              | select(.path == $path)
              | .current_version // empty
            ' |
          head -n 1
      )"

      running="$(
        printf '%s' "$installed_json" |
          jq -r \
            --arg path "$app" \
            '
              .installed[]
              | select(.path == $path)
              | .running // false
            ' |
          head -n 1
      )"

      if [[ -z "$current_version" ]]; then
        echo "Gear Lever does not currently report a Lighthouse version."
        exit 1
      fi

      echo "Installed version: $current_version"
      echo "Checking latest Harbour Masters release..."

      release_json="$(
        curl \
          --fail \
          --silent \
          --show-error \
          --location \
          --retry 3 \
          --header 'Accept: application/vnd.github+json' \
          --header 'User-Agent: nixos-lighthouse-updater' \
          'https://api.github.com/repos/HarbourMasters/Lighthouse/releases/latest'
      )"

      latest_version="$(
        printf '%s' "$release_json" |
          jq -r '.tag_name // empty'
      )"

      linux_url="$(
        printf '%s' "$release_json" |
          jq -r '
            .assets[]
            | select(.name | endswith("-Linux.zip"))
            | .browser_download_url
          ' |
          head -n 1
      )"

      linux_name="$(
        printf '%s' "$release_json" |
          jq -r '
            .assets[]
            | select(.name | endswith("-Linux.zip"))
            | .name
          ' |
          head -n 1
      )"

      if [[ -z "$latest_version" ]]; then
        echo "Could not determine the latest Lighthouse release."
        exit 1
      fi

      if [[ -z "$linux_url" ]]; then
        echo "The latest Lighthouse release has no *-Linux.zip asset."
        exit 1
      fi

      # Permit either "1.0.2" or "v1.0.2" upstream without treating
      # them as different versions.
      current_normalized="$(
        printf '%s' "$current_version" |
          sed 's/^v//'
      )"

      latest_normalized="$(
        printf '%s' "$latest_version" |
          sed 's/^v//'
      )"

      echo "Latest version:    $latest_version"
      echo "Release asset:     $linux_name"

      if [[ "$current_normalized" == "$latest_normalized" ]]; then
        echo "Lighthouse is already up to date."
        exit 0
      fi

      echo
      echo "Lighthouse update available:"
      echo "  $current_version -> $latest_version"

      if [[ "$mode" == "--check" ]]; then
        notify-send \
          "Lighthouse update available" \
          "$current_version → $latest_version. Run lighthouse-update to install it." \
          2>/dev/null || true

        exit 0
      fi

      if [[ "$running" == "true" ]]; then
        echo
        echo "Lighthouse is currently running."
        echo "Close Lighthouse and run lighthouse-update again."

        notify-send \
          "Lighthouse update postponed" \
          "Close Lighthouse before installing $latest_version." \
          2>/dev/null || true

        exit 1
      fi

      tmpdir="$(mktemp -d)"

      cleanup() {
        rm -rf "$tmpdir"
      }

      trap cleanup EXIT

      archive="$tmpdir/lighthouse-linux.zip"
      extracted="$tmpdir/extracted"

      mkdir -p "$extracted"

      echo
      echo "Downloading $linux_name..."

      curl \
        --fail \
        --show-error \
        --location \
        --retry 3 \
        --output "$archive" \
        "$linux_url"

      echo "Extracting release..."

      unzip \
        -q \
        "$archive" \
        -d "$extracted"

      candidate="$(
        find \
          "$extracted" \
          -type f \
          -iname 'lighthouse.appimage' \
          -print \
          -quit
      )"

      if [[ -z "$candidate" ]]; then
        echo "The Linux archive did not contain lighthouse.appimage."
        exit 1
      fi

      if [[ ! -s "$candidate" ]]; then
        echo "The extracted Lighthouse AppImage is empty."
        exit 1
      fi

      chmod +x "$candidate"

      echo "Installing Lighthouse $latest_version through Gear Lever..."

      flatpak run \
        it.mijorus.gearlever \
        --integrate \
        "$candidate" \
        --replace \
        --yes

      # Lighthouse ships its SDL controller database beside the
      # AppImage. Keep that file updated too.
      controller_db="$(
        find \
          "$extracted" \
          -type f \
          -name 'gamecontrollerdb.txt' \
          -print \
          -quit
      )"

      if [[ -n "$controller_db" ]]; then
        install \
          -m 0644 \
          "$controller_db" \
          "$HOME/AppImages/gamecontrollerdb.txt"
      fi

      echo
      echo "Lighthouse update complete."

      new_version="$(
        flatpak run \
          it.mijorus.gearlever \
          --list-installed \
          --json |
          jq -r \
            --arg path "$app" \
            '
              .installed[]
              | select(.path == $path)
              | .current_version // empty
            ' |
          head -n 1
      )"

      if [[ -n "$new_version" ]]; then
        echo "Gear Lever now reports version: $new_version"
      fi

      notify-send \
        "Lighthouse updated" \
        "Lighthouse was updated to $latest_version." \
        2>/dev/null || true
    '';
  };

  # Gear Lever's normal background checker.
  #
  # Re-apply our native Gear Lever update sources before checking.
  gearleverFetchUpdates = pkgs.writeShellApplication {
    name = "gearlever-fetch-updates";

    runtimeInputs = [
      pkgs.flatpak
    ];

    text = ''
      ${configureGearleverUpdaters}/bin/configure-gearlever-updaters || true

      exec flatpak run \
        it.mijorus.gearlever \
        --fetch-updates
    '';
  };
in
{
  home.packages = [
    gearlever
    configureGearleverUpdaters
    lighthouseUpdate
  ];

  # Required Gear Lever Flatpak permissions.
  #
  # org.freedesktop.Flatpak=talk is what allows Gear Lever to launch
  # applications on the NixOS host.
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

  # Configure Jagex's native Gear Lever update source whenever the
  # user session starts. This is harmless to run repeatedly.
  systemd.user.services.gearlever-configure-updaters = {
    Unit = {
      Description = "Configure Gear Lever AppImage update sources";
    };

    Service = {
      Type = "oneshot";

      ExecStart =
        "${configureGearleverUpdaters}/bin/configure-gearlever-updaters";
    };

    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  # Ask Gear Lever to check its native update sources every 12 hours.
  systemd.user.services.gearlever-fetch-updates = {
    Unit = {
      Description = "Check Gear Lever AppImages for updates";
      After = [ "graphical-session.target" ];
    };

    Service = {
      Type = "oneshot";

      ExecStart =
        "${gearleverFetchUpdates}/bin/gearlever-fetch-updates";
    };
  };

  systemd.user.timers.gearlever-fetch-updates = {
    Unit = {
      Description = "Periodically check Gear Lever AppImages for updates";
    };

    Timer = {
      # Check once per calendar day.
      # Persistent=true catches up after the computer was powered off
      # during a scheduled check.
      OnCalendar = "daily";
      Persistent = true;
      RandomizedDelaySec = "5m";

      Unit = "gearlever-fetch-updates.service";
    };

    Install = {
      WantedBy = [ "timers.target" ];
    };
  };

  # Lighthouse cannot use Gear Lever's normal updater because its
  # Linux stable release is wrapped in a ZIP. Check GitHub every
  # 12 hours and notify when a new stable release is available.
  #
  # This timer DOES NOT install anything automatically.
  systemd.user.services.lighthouse-update-check = {
    Unit = {
      Description = "Check Lighthouse for updates";
      After = [ "graphical-session.target" ];
    };

    Service = {
      Type = "oneshot";

      ExecStart =
        "${lighthouseUpdate}/bin/lighthouse-update --check";
    };
  };

  systemd.user.timers.lighthouse-update-check = {
    Unit = {
      Description = "Periodically check Lighthouse for updates";
    };

    Timer = {
      # Check Lighthouse once per calendar day.
      # This only checks and notifies; it does not blindly install.
      OnCalendar = "daily";
      Persistent = true;
      RandomizedDelaySec = "5m";

      Unit = "lighthouse-update-check.service";
    };

    Install = {
      WantedBy = [ "timers.target" ];
    };
  };
}
