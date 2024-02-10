{
  description = "nepjua-env";
  nixConfig.bash-prompt = "[nix(nepjua)] ";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      codeOverride = pkgs.writeScriptBin "code" ''
        #!/bin/sh
        /opt/homebrew/bin/code --profile 'Default' $@
      '';
    in {
      packages.hello = pkgs.hello;

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
