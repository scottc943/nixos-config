{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix

    ../../modules/nixos/common.nix
    ../../modules/nixos/nixpkgs.nix

    ../../modules/nixos/desktop/mango.nix
    ../../modules/nixos/desktop/appimages.nix
    ../../modules/nixos/desktop/flatpak.nix
    ../../modules/nixos/desktop/gaming.nix
  ];

  networking = {
    hostName = "desktop";
    networkmanager.enable = true;
  };

  boot.loader = {
    systemd-boot = {
      enable = true;
      configurationLimit = 10;
    };

    efi.canTouchEfiVariables = true;
  };

  # Btrfs compression.
  #
  # /nix is a separate Btrfs subvolume on this installation, so it
  # receives its own mount options.
  fileSystems."/".options = lib.mkAfter [
    "compress=zstd:3"
    "noatime"
  ];

  fileSystems."/nix".options = lib.mkAfter [
    "compress=zstd:3"
    "noatime"
  ];

  fileSystems."/home".options = lib.mkAfter [
    "compress=zstd:3"
    "noatime"
  ];

  services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";
  };

  nix = {
    settings.auto-optimise-store = true;

    gc = {
      # Run garbage collection weekly and catch up if the machine
      # was powered off when the scheduled run was missed.
      automatic = true;
      dates = "weekly";
      persistent = true;
      randomizedDelaySec = "30min";

      # Keep two weeks of NixOS generations available for rollback.
      options = "--delete-older-than 14d";
    };
  };

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 25;
    priority = 100;
  };

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
    };

    nvidia = {
      open = true;
      modesetting.enable = true;
      nvidiaSettings = true;
    };
  };

  services.xserver = {
    enable = true;
    videoDrivers = [ "nvidia" ];
  };

  services.displayManager = {
    defaultSession = "mango";

    sddm = {
      enable = true;
      wayland.enable = false;
    };
  };

  users = {
    mutableUsers = true;

    users.scott = {
      isNormalUser = true;
      description = "Scott";
      shell = pkgs.zsh;

      extraGroups = [
        "audio"
        "networkmanager"
        "video"
        "wheel"
      ];
    };
  };

  home-manager = {
    # The graphical NixOS installer creates ~/.config/user-dirs.dirs
    # before Home Manager's first activation. Home Manager is supposed
    # to own this file, so explicitly permit it to replace the
    # installer-created copy.
    sharedModules = [
      {
        xdg.configFile."user-dirs.dirs".force = true;
      }
    ];

    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };

    users.scott = import ../../home/scott;
  };

  security.pam.services.swaylock = { };

  system.stateVersion = "26.05";
}
