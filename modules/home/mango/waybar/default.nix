{
  inputs,
  pkgs,
  ...
}:
let
  system = pkgs.stdenv.hostPlatform.system;
  mangoPackage = inputs.mangowm.packages.${system}.default;

  weatherScript = pkgs.writeShellApplication {
    name = "waybar-weather";

    runtimeInputs = with pkgs; [
      coreutils
      curl
      gawk
      gnugrep
      gnused
    ];

    text = builtins.readFile ./scripts/weather.sh;
  };

  mangoTagScript = pkgs.writeShellApplication {
    name = "waybar-mango-tag";

    runtimeInputs = [
      mangoPackage
      pkgs.coreutils
      pkgs.gawk
      pkgs.gnugrep
      pkgs.gnused
      pkgs.jq
    ];

    text = builtins.readFile ./scripts/mango-tag.sh;
  };

  waybarConfig = pkgs.runCommand "waybar-config" { } ''
    substitute ${./config} "$out" \
      --replace-fail \
        '~/.config/waybar/scripts/weather.sh' \
        '${weatherScript}/bin/waybar-weather' \
      --replace-fail \
        '~/.config/waybar/scripts/mango-tag.sh' \
        '${mangoTagScript}/bin/waybar-mango-tag'
  '';
in
{
  home.packages = [
    mangoTagScript
    weatherScript
  ];

  programs.waybar = {
    enable = true;

    systemd = {
      enable = true;
      targets = [ "mango-session.target" ];
    };
  };

  xdg.configFile = {
    "waybar/config".source = waybarConfig;
    "waybar/style.css".source = ./style.css;

    "waybar/theme.css" = {
      source = ./theme.css;
    };

    "waybar/user-style.css" = {
      source = ./user-style.css;
    };

    "waybar/includes" = {
      source = ./includes;
      recursive = true;
    };

    "waybar/themes" = {
      source = ./themes;
      recursive = true;
    };
  };

  systemd.user.services.waybar.Service = {
    Restart = "on-failure";
    RestartSec = 2;
  };
}
