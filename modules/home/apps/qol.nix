{ pkgs, ... }:

{
  # ------------------------------------------------------------
  # Automatic per-project development environments
  # ------------------------------------------------------------
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;

    nix-direnv = {
      enable = true;
    };
  };

  # ------------------------------------------------------------
  # Faster shell navigation
  #
  # Examples:
  #   z nixos
  #   z project
  #   zi
  # ------------------------------------------------------------
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  # ------------------------------------------------------------
  # Fuzzy searching
  #
  # CTRL+T -> files
  # CTRL+R -> command history
  # ALT+C  -> directories
  # ------------------------------------------------------------
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;

    defaultCommand = "fd --type f --hidden --follow --exclude .git";

    fileWidgetCommand =
      "fd --type f --hidden --follow --exclude .git";

    changeDirWidgetCommand =
      "fd --type d --hidden --follow --exclude .git";

    defaultOptions = [
      "--height=40%"
      "--layout=reverse"
      "--border"
    ];
  };

  # ------------------------------------------------------------
  # Better terminal file viewing
  # ------------------------------------------------------------
  programs.bat = {
    enable = true;

    config = {
      pager = "less -FR";
    };
  };

  # ------------------------------------------------------------
  # Better directory listings
  # ------------------------------------------------------------
  programs.eza = {
    enable = true;
    enableZshIntegration = true;

    icons = "auto";
    git = true;

    extraOptions = [
      "--group-directories-first"
      "--header"
    ];
  };

  # ------------------------------------------------------------
  # Better Git diffs
  # ------------------------------------------------------------
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
  };

  # ------------------------------------------------------------
  # Miscellaneous development / diagnostic tools
  # ------------------------------------------------------------
  home.packages = with pkgs; [
    # Nix
    nixd
    nixfmt
    statix

    # Shell scripting
    shellcheck
    shfmt

    # Useful structured-data CLI tools
    yq

    # System monitoring
    bottom
  ];

  # ------------------------------------------------------------
  # Small cross-shell aliases
  # ------------------------------------------------------------
  home.shellAliases = {
    # Modern directory listings.
    ll = "eza -lah --git";
    la = "eza -a";
    lt = "eza --tree --level=2";

    # Keep the original cat available when necessary.
    ccat = "command cat";

    # Handy NixOS config shortcuts.
    nxc = "cd ~/nixos-config";
    nxcheck = "cd ~/nixos-config && nix flake check";
    nxbuild = "cd ~/nixos-config && nix build '.#nixosConfigurations.desktop.config.system.build.toplevel' --no-link";

    # Git conveniences.
    gs = "git status";
    gd = "git diff";
    gl = "git log --oneline --decorate --graph";
  };
}
