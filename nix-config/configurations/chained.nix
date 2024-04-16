{
  inputs,
  flake,
}: let
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
      ../darwin/chained.nix
      nix-index-database.nixosModules.nix-index
      {programs.nix-index-database.comma.enable = true;}
      home-manager.darwinModules.home-manager
      {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          backupFileExtension = "backup";
          users.yahmet = {...}: {
            imports = [
              ../home/src/extensions/extra-paths/__enter.nix
              ../home/profiles/minimal

              ../home/profiles/darwin/yahmet.nix

              ../home/src/extensions/extra-paths/__exit.nix
            ];
          };
          extraSpecialArgs = {inherit inputs;};
        };
      }
    ];
  }
