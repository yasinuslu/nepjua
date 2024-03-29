{
  description = "Nepjua Root Flake";
  nixConfig.bash-prompt = "[nix(nepjua)] ";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/master";
    flake-utils.url = "github:numtide/flake-utils";
    alejandra.url = "github:kamadorueda/alejandra/3.0.0";
    alejandra.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    flake-utils,
    nixpkgs,
    alejandra,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      codeOverride = pkgs.writeScriptBin "code" ''
        #!/usr/bin/env bash
        CODE_EXEC="$(type -a code | awk '{sub(/^code is /, ""); print}' | awk 'NR==2')"
        "$CODE_EXEC" --profile Default "$@"
      '';
    in {
      packages.hello = pkgs.hello;

      formatter = alejandra.defaultPackage.${system};

      devShell = pkgs.mkShell {
        name = "nepjua";
        buildInputs = [codeOverride];
        shellHook = ''
          echo "Welcome in $name"
          export HF_HUB_ENABLE_HF_TRANSFER=1
        '';
      };
    });
}
