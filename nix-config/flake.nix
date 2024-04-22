{
  description = "Nepjua Nix Config";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    darwin.url = "github:lnl7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    nix-colors.url = "github:misterio77/nix-colors";

    nix-index-database.url = "github:Mic92/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    nix-alien.url = "github:thiagokokada/nix-alien";
    nix-alien.inputs.nixpkgs.follows = "nixpkgs";

    flake-compat.url = "github:edolstra/flake-compat";
    flake-compat.flake = false;
  };

  outputs = {...} @ inputs: let
    myLib = import ./my-lib/default.nix {inherit inputs;};
  in
    with myLib; {
      nixosConfigurations = {
        kaori = mkSystem ./hosts/kaori/configuration.nix;
      };

      darwinConfigurations = {
        joyboy = mkDarwinSystem ./hosts/joyboy/configuration.nix;
      };

      devShell = forAllSystems (system: let
        pkgs = inputs.nixpkgs.legacyPackages.${system};
      in
        pkgs.mkShell {
          name = "default";
          buildInputs = [
            pkgs.just
            pkgs.alejandra
          ];
          shellHook = ''
            echo "Welcome in $name"
            export HF_HUB_ENABLE_HF_TRANSFER=1
          '';
        });

      myLib.default = myLib;
      homeManagerModules.default = import ./modules/home-manager;
      nixosModules.default = ./modules/nixos;
      darwinModules.default = ./modules/darwin;
      formatter = forAllSystems (system: inputs.nixpkgs.legacyPackages.${system}.alejandra);
    };
}
