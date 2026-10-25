{
  description = "NixOS de peppi: ThinkPad E14 (i5-1235U) + VM de pruebas";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware";

    stylix = {
      url = "github:nix-community/stylix/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, stylix, nixos-hardware, ... }@inputs:
    let
      mkHost = name: extra: nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = extra ++ [
          ./hosts/${name}
          home-manager.nixosModules.home-manager
          stylix.nixosModules.stylix
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "hm-bak";
              users.peppi = import ./home;
            };
          }
        ];
      };
    in
    {
      nixosConfigurations = {
        vm = mkHost "vm" [ ];
        laptop = mkHost "laptop" [ nixos-hardware.nixosModules.lenovo-thinkpad-e14-intel-gen4 ];
      };
    };
}
