{
  inputs,
  outputs,
}: let
  inherit (inputs) nixpkgs home-manager;
in
  nixpkgs.lib.nixosSystem {
    specialArgs = {inherit inputs outputs;};
    modules = [
      outputs.nixosModules.default
      home-manager.nixosModules.home-manager
      {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          users.nepjua = outputs.homeManagerModules.default;
          extraSpecialArgs = {inherit inputs outputs;};
        };
      }
    ];
  }
