{ pkgs, ... }:

let
  lockCmd = "${pkgs.swaylock}/bin/swaylock -f";
in
{
  programs.swaylock = {
    enable = true;

    settings = {
      show-failed-attempts = true;

      # Background image
      image = ../../../assets/lockscreen.jpg;
      scaling = "fill";

      # Nice defaults
      font = "JetBrainsMono Nerd Font";
      "indicator-radius" = 120;
      "indicator-thickness" = 10;

      "inside-color" = "1e1e2ecc";
      "ring-color" = "89b4faff";
      "key-hl-color" = "a6e3a1ff";
      "bs-hl-color" = "f38ba8ff";
      "text-color" = "cdd6f4ff";
      "separator-color" = "00000000";
      "line-color" = "00000000";
    };
  };

  services.swayidle = {
    enable = true;

    events = {
      lock = lockCmd;
      before-sleep = lockCmd;
    };

    timeouts = [
      {
        # Lock after 10 minutes idle
        timeout = 600;
        command = lockCmd;
      }
    ];
  };
}
