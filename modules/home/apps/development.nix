{ pkgs, ... }:

let
  # CBMC is the CPROVER bounded model checker.
  #
  # Prefer it when available in the pinned Nixpkgs revision. If it is
  # unavailable, fall back to Frama-C when that package exists.
  formalVerification =
    if builtins.hasAttr "cbmc" pkgs then
      [ pkgs.cbmc ]
    else if builtins.hasAttr "frama-c" pkgs then
      [ pkgs."frama-c" ]
    else
      [ ];
in
{
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;

    profiles.default.userSettings = {
      "editor.fontFamily" = "'JetBrainsMono Nerd Font'";
      "editor.fontLigatures" = true;
      "editor.formatOnSave" = true;

      "files.autoSave" = "afterDelay";

      "terminal.integrated.defaultProfile.linux" = "zsh";

      "window.titleBarStyle" = "custom";
    };
  };

  home.packages =
    (with pkgs; [
      # ------------------------------------------------------------
      # General development tools
      # ------------------------------------------------------------
      jq
      just
      ripgrep
      fd
      curl
      wget

      # ------------------------------------------------------------
      # React / JavaScript / TypeScript
      #
      # nodejs includes node, npm and npx.
      # React dependencies themselves should remain per-project.
      # ------------------------------------------------------------
      nodejs
      typescript
      typescript-language-server
      prettier
      eslint
      vscode-langservers-extracted

      # ------------------------------------------------------------
      # Python
      # ------------------------------------------------------------
      python3
      uv
      ruff
      pyright

      # ------------------------------------------------------------
      # Go
      # ------------------------------------------------------------
      go
      gopls
      delve
      golangci-lint
      gofumpt

      # ------------------------------------------------------------
      # C / C++
      # ------------------------------------------------------------
      gcc
      clang-tools

      cmake
      gnumake
      ninja
      pkg-config

      autoconf
      automake
      libtool

      gdb
      lldb
      valgrind

      # Useful SMT solver for formal verification work.
      z3

      # ------------------------------------------------------------
      # Rust
      # ------------------------------------------------------------
      rustc
      cargo
      rust-analyzer
      clippy
      rustfmt

      # ------------------------------------------------------------
      # Java
      # ------------------------------------------------------------
      jdk21
      maven
      gradle
      jdt-language-server

      # ------------------------------------------------------------
      # NvChad / Lua tooling
      # ------------------------------------------------------------
      lua-language-server
      stylua
    ])
    ++ formalVerification;
}
