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

    proxmos-nixos = {
      url = "github:yasinuslu/proxmox-nixos/a1ec78293b526ed848cc04f2afc5f9079ffaad60";
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
        gitignore,
        flake-root,
        ...
      }:
      let
        # Dynamically load all flake modules from modules/flake directory
        flakeModules =
          let
            # Get the directory contents
            flakeModulesDir = ./modules/flake;
            dirContents = builtins.readDir flakeModulesDir;

            # Filter for .nix files
            nixFiles = builtins.filter (name: builtins.match ".*\\.nix" name != null) (
              builtins.attrNames dirContents
            );

            # Create an attrset of modules where:
            # - key is the filename without .nix extension
            # - value is a function that takes localFlake and returns the module
            mkModule =
              name:
              let
                modulePath = flakeModulesDir + "/${name}";
                moduleName = builtins.replaceStrings [ ".nix" ] [ "" ] name;
              in
              {
                name = moduleName;
                value = flake-parts-lib.importApply modulePath { inherit withSystem; };
              };
          in
          builtins.listToAttrs (map mkModule nixFiles);
      in
      {
        imports = [
          inputs.flake-root.flakeModule
        ] ++ builtins.attrValues flakeModules;
        systems = [
          "x86_64-linux"
          "aarch64-linux"
          "aarch64-darwin"
          "x86_64-darwin"
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
            _module.args.pkgs = import nixpkgs {
              inherit system;
              config.allowUnfree = true;
            };
          };
        flake = {
          # Export the flake modules for others to use
          inherit flakeModules;
          # those are more easily expressed in perSystem.
          # Define flake-wide options
        };
      }
    );
}
