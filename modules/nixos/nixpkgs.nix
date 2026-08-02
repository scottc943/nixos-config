{ lib, ... }:
{
  # Permit only the proprietary packages intentionally selected below.
  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "clion"
      "discord"
      "idea"
      "pycharm"
      "rider"
      "rust-rover"
      "steam"
      "steam-original"
      "steam-run"
      "steam-unwrapped"
      "nvidia-settings"
      "nvidia-x11"
      "vscode"
    ];
}
