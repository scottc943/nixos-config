{ ... }:
{
  services.dunst = {
    enable = true;
    configFile = ./dunstrc;
  };

  systemd.user.services.dunst.Service = {
    Restart = "on-failure";
    RestartSec = 2;
  };
}
