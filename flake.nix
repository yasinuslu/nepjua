{
  description = "Nepjua Nix Config";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
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

    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    { ... }@inputs:
    let
      myLib = import ./my-lib/default.nix { inherit inputs; };
    in
    with myLib;
    {
      nixosConfigurations = {
        kaori = mkSystem defaultSystems.linux ./hosts/kaori/configuration.nix;
        pve-sezer = mkSystem "x86_64-linux" ./hosts/pve/sezer/configuration.nix;
        pve-nepjua = mkSystem "x86_64-linux" ./hosts/pve/nepjua/configuration.nix;
        pve-abulut = mkSystem "x86_64-linux" ./hosts/pve/abulut/configuration.nix;
        pve-talha = mkSystem "x86_64-linux" ./hosts/pve/talha/configuration.nix;
      };

      darwinConfigurations = {
        joyboy = mkDarwinSystem defaultSystems.darwin ./hosts/joyboy/configuration.nix;
        sezer = mkDarwinSystem "x86_64-darwin" ./hosts/sezer/configuration.nix;
        chained = mkDarwinSystem defaultSystems.darwin ./hosts/chained/configuration.nix;
      };

      devShell = eachSystem (
        pkgs:
        let
          masterNixpkgs = inputs.masterNixpkgs.legacyPackages.${pkgs.system};
          myShell = import ./my-shell/default.nix {
            inherit
              system
              pkgs
              inputs
              myLib
              masterNixpkgs
              ;
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
      # for `nix fmt`
      formatter = eachSystem (pkgs: treefmtEval.${pkgs.system}.config.build.wrapper);
      # for `nix flake check`
      checks = eachSystem (pkgs: {
        formatting = treefmtEval.${pkgs.system}.config.build.check self;
      });
    };
}
