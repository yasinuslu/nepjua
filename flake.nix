{
  description = "Description for the project";

  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };

    masterNixpkgs = {
      url = "github:NixOS/nixpkgs/master";
    };

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-root = {
      url = "github:srid/flake-root";
      inputs.nixpkgs.follows = "nixpkgs";
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
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-alien = {
      url = "github:thiagokokada/nix-alien";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      flake-parts,
      nixpkgs,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } (
      flakePartsArgs@{
        withSystem,
        flake-parts-lib,
        flake-root,
        ...
      }:
      let
        lib = nixpkgs.lib;
        myLib = import ./my-lib {
          lib = nixpkgs.lib;
          inherit inputs;
        };
        moduleArgs = flakePartsArgs // {
          inherit lib;
          inherit (flake-parts-lib) importApply;
          inherit inputs;
        };

        # Auto-discover all modules
        allModules = myLib.discoverModules {
          baseDir = ./modules;
          topModuleArgs = moduleArgs;
        };
      in
      {
        imports = [
          inputs.flake-root.flakeModule
          inputs.treefmt-nix.flakeModule
        ] ++ allModules.flat;

        systems = [
          "x86_64-linux"
          "aarch64-linux"
          "aarch64-darwin"
          "x86_64-darwin"
        ];
        perSystem =
          {
            system,
            ...
          }:
          {
            _module.args.masterNixpkgs = import inputs.masterNixpkgs {
              inherit system;
            };
            # This sets `pkgs` to a nixpkgs with allowUnfree option set.
            _module.args.pkgs = import nixpkgs {
              inherit system;
              config.allowUnfree = true;
            };
          };
        flake = {
          flakeModules = allModules.nested;
        };
      }
    );
}
