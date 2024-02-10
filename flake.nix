{
  description = "Nepjua Root Flake";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/master";

    alejandra.url = "github:kamadorueda/alejandra/3.0.0";
    alejandra.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    alejandra,
    ...
  }: {
    formatter.x86_64-linux = alejandra.defaultPackage."x86_64-linux";
    formatter.aarch64-darwin = alejandra.defaultPackage."aarch64-darwin";
  };
}
