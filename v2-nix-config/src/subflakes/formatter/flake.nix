{
  description = "Subflake for downloading and setting formatter";

  inputs = {
    nixpkgs = {};
    root = {};
    alejandra.url = "github:kamadorueda/alejandra/3.0.0";
    alejandra.inputs.nixpkgs.follows = "nixpkgs";
    alejandra.inputs.flakeCompat.follows = "root/flake-compat";
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
