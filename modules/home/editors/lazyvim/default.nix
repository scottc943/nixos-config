{ pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    # LazyVim manages Neovim plugins. Nix supplies the external commands that
    # plugins commonly invoke so those tools are reproducible and available.
    extraPackages = with pkgs; [
      curl
      fd
      fzf
      gcc
      git
      gnumake
      lazygit
      nodejs
      python3
      ripgrep
      tree-sitter
      unzip
    ];
  };

  # Deploy individual files instead of symlinking the whole nvim directory.
  # This leaves ~/.local/state/nvim writable for LazyVim's plugin lock file.
  xdg.configFile = {
    "nvim/init.lua".source = ./files/init.lua;
    "nvim/lua/config/lazy.lua".source = ./files/lua/config/lazy.lua;
    "nvim/lua/config/options.lua".source = ./files/lua/config/options.lua;
    "nvim/lua/config/keymaps.lua".source = ./files/lua/config/keymaps.lua;
    "nvim/lua/config/autocmds.lua".source = ./files/lua/config/autocmds.lua;
    "nvim/lua/plugins/user.lua".source = ./files/lua/plugins/user.lua;
  };
}
