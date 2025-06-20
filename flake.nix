{
  description = "Nepjua Nix Config";

  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
    };

    nixos-unified = {
      url = "github:srid/nixos-unified";
    };

    flake-root = {
      url = "github:srid/flake-root";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-colors = {
      url = "github:misterio77/nix-colors";
    };

    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-alien = {
      url = "github:thiagokokada/nix-alien";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # proxmos-nixos = {
    #   url = "github:yasinuslu/proxmox-nixos/a1ec78293b526ed848cc04f2afc5f9079ffaad60";
    # };

  };

  outputs =
    {
      flake-parts,
      ...
    }@inputs:
    let
      myLib = import ./my-lib/default.nix { inherit inputs; };
    in
    with myLib;
    flake-parts.lib.mkFlake { inherit inputs; } (
      {
        ...
      }:
      {
        imports = [ inputs.flake-root.flakeModule ];
        systems = [
          "x86_64-linux"
          # "aarch64-linux"
          "aarch64-darwin"
          # "x86_64-darwin"
        ];
        perSystem =
          {
            config,
            pkgs,
            system,
            ...
          }:
          {
            # This sets `pkgs` to a nixpkgs with allowUnfree option set.
            _module.args.pkgs = import inputs.nixpkgs {
              inherit system;
              config = {
                allowUnfree = true;
                allowUnsupportedSystem = false;
                permittedInsecurePackages = [
                  "electron-32.3.3"
                ];
              };
            };

            # For 'nix fmt'
            formatter = pkgs.nixfmt-rfc-style;

            devShells.default =
              let
                myShell = import ./my-shell/default.nix {
                  inherit
                    system
                    pkgs
                    inputs
                    myLib
                    ;
                };
              in
              myShell.mkShell {
                # This is just to be able to trigger a rebuild when I want to
                version = "0.0.2";
                inputsFrom = [ config.flake-root.devShell ];
              };
          };
        flake = {
          nixosConfigurations = {
            kaori = mkSystem defaultSystems.linux ./hosts/kaori/configuration.nix;
            nari = mkSystem defaultSystems.linux ./hosts/nari/configuration.nix;
            nika = mkSystem defaultSystems.linux ./hosts/nika/configuration.nix;
          };

          darwinConfigurations = {
            joyboy = mkDarwinSystem defaultSystems.darwin ./hosts/joyboy/configuration.nix;
            sezer = mkDarwinSystem defaultSystems.darwin ./hosts/sezer/configuration.nix;
            chained = mkDarwinSystem defaultSystems.darwin ./hosts/chained/configuration.nix;
          };

          homeManagerModules.default = ./modules/home-manager;
          nixosModules.default = ./modules/nixos;
          darwinModules.default = ./modules/darwin;
          myLib.default = myLib;
        };
      }
    );
}
