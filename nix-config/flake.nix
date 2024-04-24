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
        kaori = mkSystem defaultSystems.linux ./hosts/kaori/configuration.nix;
      };

      darwinConfigurations = {
        joyboy = mkDarwinSystem defaultSystems.darwin ./hosts/joyboy/configuration.nix;
        chained = mkDarwinSystem defaultSystems.darwin ./hosts/chained/configuration.nix;
      };

      devShell = forAllSystems (system: let
        pkgs = inputs.nixpkgs.legacyPackages.${system};
      in
        with pkgs;
          mkShell {
            name = "default";
            buildInputs = [
              just
              alejandra
            ];
            shellHook = ''
              echo "Welcome in $name"
              export HF_HUB_ENABLE_HF_TRANSFER=1
              export PATH=$HOME/.local/bin:$PATH
              export PATH=$HOME/.console-ninja/.bin:$PATH
            '';
          });

      myLib.default = myLib;
      homeManagerModules.default = ./modules/home-manager;
      nixosModules.default = ./modules/nixos;
      darwinModules.default = ./modules/darwin;
      formatter = forAllSystems (system: inputs.nixpkgs.legacyPackages.${system}.alejandra);
    };
}
