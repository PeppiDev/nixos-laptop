{
  description = "NixOS de peppi: ThinkPad E14 (i5-1235U) + VM de pruebas";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
  };

  outputs = { self, nixpkgs, ... }@inputs:
    let
      mkHost = name: nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [ ./hosts/${name} ];
      };
    in
    {
      nixosConfigurations = {
        vm = mkHost "vm";
      };
    };
}
