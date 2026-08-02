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

  # The installer created /nix as its own Btrfs subvolume, so compression
  # must be enabled for that mount separately from the root filesystem.
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
      automatic = true;
      dates = "weekly";
      randomizedDelaySec = "45min";
      options = "--delete-older-than 30d";
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
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };
    users.scott = import ../../home/scott;
  };

  system.stateVersion = "26.05";
}
