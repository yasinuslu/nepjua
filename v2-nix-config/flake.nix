{
  description = "Nepjua Nix Config";

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

    nix-colors.url = "github:misterio77/nix-colors";

    alejandra.url = "github:kamadorueda/alejandra/3.0.0";
    alejandra.inputs.nixpkgs.follows = "nixpkgs";

    nix-index-database.url = "github:Mic92/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    nix-alien.url = "github:thiagokokada/nix-alien";

    flake-compat = {
      url = "github:inclyc/flake-compat";
      flake = false;
    };

    formatter = {
      url = "path:./src/subflakes/formatter";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    ...
  }: {
    bar = "bar";
    formatter = self.inputs.formatter.outputs.formatter-config;

    # darwinConfigurations = {
    #   saiko = (import ./machines/saiko) {
    #     inputs = self.inputs;
    #     flake = self;
    #   };
    # };
  };
}
