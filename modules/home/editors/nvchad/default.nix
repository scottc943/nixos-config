{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;

    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    # Tools NvChad itself needs.
    #
    # Language compilers, formatters, debuggers and LSP servers are
    # provided by modules/home/apps/development.nix.
    extraPackages = with pkgs; [
      curl
      fd
      fzf
      gcc
      git
      gnumake
      lazygit
      ripgrep
      tree-sitter
      unzip
    ];
  };

  # Keep the NvChad configuration itself in Git/Nix.
  #
  # Plugin downloads and runtime state remain under ~/.local/share/nvim
  # and ~/.local/state/nvim.
  xdg.configFile."nvim" = {
    source = ./config;
    recursive = true;
  };
}
