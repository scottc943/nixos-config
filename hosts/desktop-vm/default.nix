{
  inputs,
  modulesPath,
  pkgs,
  ...
}:
{
  imports = [
    (modulesPath + "/virtualisation/qemu-vm.nix")
    ../../modules/nixos/common.nix
    ../../modules/nixos/nixpkgs.nix
    ../../modules/nixos/desktop/mango.nix
    ../../modules/nixos/desktop/appimages.nix
    ../../modules/nixos/desktop/flatpak.nix
  ];

  networking.hostName = "desktop-vm";


  users.users.scott = {
    isNormalUser = true;
    description = "Scott";
    initialPassword = "nixos";
    shell = pkgs.zsh;
    extraGroups = [
      "audio"
      "networkmanager"
      "video"
      "wheel"
    ];
  };

  services.xserver.enable = true;
  services.displayManager.defaultSession = "mango";
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = false;
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };
    users.scott = import ../../home/scott;
  };

  virtualisation = {
    memorySize = 8192;
    cores = 4;
    diskSize = 32768;

    # Avoid QEMU's default emulated VGA adapter. Use VirtIO GPU's
    # non-accelerated 2D backend first so host OpenGL is not involved.
    qemu.options = [
      "-vga none"
      "-device virtio-gpu-pci"
      "-display gtk,gl=off"
    ];
  };

  system.stateVersion = "26.05";
}
