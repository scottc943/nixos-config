{
  description = "Scott's reproducible NixOS desktop and VM configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mangowm = {
      url = "github:mangowm/mango?rev=e670b890bdd252459b33115cf6ba8c8007348638";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-flatpak.url =
      "github:gmodena/nix-flatpak/?ref=v0.7.0";
  };

  outputs =
    inputs@{
      nixpkgs,
      home-manager,
      mangowm,
      nix-flatpak,
      ...
    }:
    {
      nixosConfigurations.desktop-vm = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };

        modules = [
          mangowm.nixosModules.mango
          nix-flatpak.nixosModules.nix-flatpak
          home-manager.nixosModules.home-manager
          ./hosts/desktop-vm
        ];
      };
    };
}
