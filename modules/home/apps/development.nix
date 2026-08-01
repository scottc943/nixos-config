{ pkgs, ... }:
{
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;

    profiles.default.userSettings = {
      "editor.fontFamily" = "'JetBrainsMono Nerd Font', monospace";
      "editor.fontLigatures" = true;
      "editor.formatOnSave" = true;
      "files.autoSave" = "afterDelay";
      "terminal.integrated.defaultProfile.linux" = "zsh";
      "window.titleBarStyle" = "custom";
    };
  };

  home.packages = with pkgs; [
    git
    jq
    just
    ripgrep
  ];
}
