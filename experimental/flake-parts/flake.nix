{
  description = "Description for the project";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    masterNixpkgs.url = "github:NixOS/nixpkgs/master";
    flake-parts.url = "github:hercules-ci/flake-parts";

    flake-root.url = "github:srid/flake-root";

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
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
      {
        withSystem,
        flake-parts-lib,
        flake-root,
        ...
      }:
      let
        inherit (flake-parts-lib) importApply;
        myLib = import ./my-lib {
          lib = nixpkgs.lib;
          inherit inputs;
        };
        moduleArgs = {
          inherit
            inputs
            nixpkgs
            flake-parts-lib
            importApply
            withSystem
            flake-root
            ;
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
