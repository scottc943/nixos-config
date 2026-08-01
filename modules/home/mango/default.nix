{
  inputs,
  pkgs,
  ...
}:
let
  system = pkgs.stdenv.hostPlatform.system;
  mangoPackage = inputs.mangowm.packages.${system}.default;

  sessionInit = pkgs.writeShellApplication {
    name = "mango-session-init";
    runtimeInputs = with pkgs; [
      dbus
      systemd
    ];
    text = builtins.readFile ./scripts/session-init.sh;
  };

  wallpaperScript = pkgs.writeShellApplication {
    name = "mango-wallpaper";
    runtimeInputs = with pkgs; [
      awww
      libnotify
      procps
    ];
    text = builtins.readFile ./scripts/wallpaper.sh;
  };

  clipboardMenu = pkgs.writeShellApplication {
    name = "mango-clipboard-menu";
    runtimeInputs = with pkgs; [
      cliphist
      rofi
      wl-clipboard
    ];
    text = builtins.readFile ./scripts/clipboard-menu.sh;
  };

  clipboardClear = pkgs.writeShellApplication {
    name = "mango-clipboard-clear";
    runtimeInputs = with pkgs; [
      cliphist
      libnotify
    ];
    text = builtins.readFile ./scripts/clipboard-clear.sh;
  };

  screenshotScript = pkgs.writeShellApplication {
    name = "mango-screenshot";
    runtimeInputs = with pkgs; [
      coreutils
      grim
      satty
      slurp
      wl-clipboard
    ];
    text = builtins.readFile ./scripts/screenshot.sh;
  };
in
{
  imports = [
    ./dunst
    ./rofi
    ./waybar
  ];

  # Home Manager's Wayland-aware services now bind to the Mango session
  # target instead of being duplicated as hand-written services.
  wayland.systemd.target = "mango-session.target";

  home.packages = with pkgs; [
    clipboardClear
    clipboardMenu
    cliphist
    grim
    libnotify
    mangoPackage
    pamixer
    polkit_gnome
    satty
    screenshotScript
    sessionInit
    slurp
    wallpaperScript
    wl-clipboard
  ];

  home.file."Pictures/Wallpapers/NGE4PromoPenPen.png".source =
    ../../../assets/wallpapers/NGE4PromoPenPen.png;

  xdg.configFile."mango/config.conf".source = ./config.conf;

  systemd.user.targets.mango-session = {
    Unit = {
      Description = "Mango compositor session";
      BindsTo = [ "graphical-session.target" ];
      Wants = [ "graphical-session-pre.target" ];
      After = [ "graphical-session-pre.target" ];
    };
  };

  systemd.user.services = {
    mango-wallpaper = {
      Unit = {
        Description = "Mango wallpaper";
        PartOf = [ "mango-session.target" ];
        After = [ "graphical-session-pre.target" ];
      };
      Service = {
        Type = "oneshot";
        ExecStart = "${wallpaperScript}/bin/mango-wallpaper";
        RemainAfterExit = true;
      };
      Install.WantedBy = [ "mango-session.target" ];
    };

    mango-clipboard-text = {
      Unit = {
        Description = "Mango text clipboard history";
        PartOf = [ "mango-session.target" ];
        After = [ "graphical-session-pre.target" ];
      };
      Service = {
        ExecStart = "${pkgs.wl-clipboard}/bin/wl-paste --type text --watch ${pkgs.cliphist}/bin/cliphist store";
        Restart = "on-failure";
        RestartSec = 2;
      };
      Install.WantedBy = [ "mango-session.target" ];
    };

    mango-clipboard-image = {
      Unit = {
        Description = "Mango image clipboard history";
        PartOf = [ "mango-session.target" ];
        After = [ "graphical-session-pre.target" ];
      };
      Service = {
        ExecStart = "${pkgs.wl-clipboard}/bin/wl-paste --type image --watch ${pkgs.cliphist}/bin/cliphist store";
        Restart = "on-failure";
        RestartSec = 2;
      };
      Install.WantedBy = [ "mango-session.target" ];
    };

    mango-polkit-agent = {
      Unit = {
        Description = "Mango graphical Polkit agent";
        PartOf = [ "mango-session.target" ];
        After = [ "graphical-session-pre.target" ];
      };
      Service = {
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 2;
      };
      Install.WantedBy = [ "mango-session.target" ];
    };
  };
}
