{
  description = "Nepjua Root Flake";
  nixConfig.bash-prompt = "[nepjua(nodejs_18)] ";

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
    in {
      packages.hello = pkgs.hello;

      formatter = alejandra.defaultPackage.${system};

      devShell = pkgs.mkShell {
        name = "nepjua";
        buildInputs = [
          pkgs.nodejs_18
        ];
        shellHook = ''
          echo "Welcome in $name"
          export HF_HUB_ENABLE_HF_TRANSFER=1
        '';
      };
    });
}
