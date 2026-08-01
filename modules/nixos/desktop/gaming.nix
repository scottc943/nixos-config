{ pkgs, ... }:
{
  # Physical desktop only. Do not import this module into desktop-vm.
  programs = {
    gamemode.enable = true;

    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
    };
  };

  environment.systemPackages = with pkgs; [
    protontricks
  ];
}
