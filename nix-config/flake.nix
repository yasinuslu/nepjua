{
  description = "Your new nix config";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/master";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # hardware.url = "github:nixos/nixos-hardware";

    # Shameless plug: looking for a way to nixify your themes and make
    # everything match nicely? Try nix-colors!
    nix-colors.url = "github:misterio77/nix-colors";

    alejandra.url = "github:kamadorueda/alejandra/3.0.0";
    alejandra.inputs.nixpkgs.follows = "nixpkgs";

    nix-index-database.url = "github:Mic92/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    vscode-server.url = "github:nix-community/nixos-vscode-server";

    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";

    nix-alien.url = "github:thiagokokada/nix-alien";

    nixgl.url = "github:guibou/nixGL";

    flake-compat = {
      url = "github:inclyc/flake-compat";
      flake = false;
    };
  };

  outputs = {
    self,
    alejandra,
    ...
  }: {
    formatter.x86_64-linux = alejandra.defaultPackage."x86_64-linux";
    formatter.aarch64-darwin = alejandra.defaultPackage."aarch64-darwin";
    # NixOS configuration entrypoint
    # Available through 'nixos-rebuild --flake .#your-hostname'
    nixosConfigurations = {
      kaori = import ./configurations/kaori.nix {
        inputs = self.inputs;
        flake = self;
      };

      hetzner = import ./configurations/hetzner.nix {
        inputs = self.inputs;
        flake = self;
      };

      tristan = import ./configurations/tristan.nix {
        inputs = self.inputs;
        flake = self;
      };
    };

    darwinConfigurations = {
      raiden = (import ./configurations/raiden.nix) {
        inputs = self.inputs;
        flake = self;
      };

      chained = (import ./configurations/chained.nix) {
        inputs = self.inputs;
        flake = self;
      };
    };
  };
}
