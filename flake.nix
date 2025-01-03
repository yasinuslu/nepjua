{
  description = "Nepjua Nix Config";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    masterNixpkgs.url = "github:NixOS/nixpkgs/master";

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
        proxmox-base = mkSystem "x86_64-linux" ./hosts/proxmox/base/configuration.nix;
      };

      darwinConfigurations = {
        joyboy = mkDarwinSystem defaultSystems.darwin ./hosts/joyboy/configuration.nix;
        sezer = mkDarwinSystem "x86_64-darwin" ./hosts/sezer/configuration.nix;
        chained = mkDarwinSystem defaultSystems.darwin ./hosts/chained/configuration.nix;
      };

      devShell = forAllSystems (
        system: let
          pkgs = inputs.nixpkgs.legacyPackages.${system};
          masterNixpkgs = inputs.masterNixpkgs.legacyPackages.${system};
          myShell = import ./my-shell/default.nix {
            inherit system pkgs inputs myLib masterNixpkgs;
          };
        in
          myShell.mkShell {
            # This is just to be able to trigger a rebuild when I want to
            version = "0.0.2";
          }
      );

      myLib.default = myLib;
      homeManagerModules.default = ./modules/home-manager;
      nixosModules.default = ./modules/nixos;
      darwinModules.default = ./modules/darwin;
      formatter = forAllSystems (system: inputs.nixpkgs.legacyPackages.${system}.alejandra);
    };
}
