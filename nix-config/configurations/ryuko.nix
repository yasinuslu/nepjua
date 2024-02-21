{inputs}: let
  inherit
    (inputs)
    darwin
    alejandra
    nix-index-database
    home-manager
    ;
in
  darwin.lib.darwinSystem {
    system = "aarch64-darwin";
    modules = [
      ../utils
      {
        environment.systemPackages = [
          alejandra.defaultPackage."aarch64-darwin"
        ];
      }
      ../darwin/ryuko.nix
      nix-index-database.nixosModules.nix-index
      {programs.nix-index-database.comma.enable = true;}
      home-manager.darwinModules.home-manager
      {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          users.musu = import ../home/profiles/musu-darwin;
          extraSpecialArgs = {inherit inputs;};
        };
      }
    ];
  }
