localFlake:
{
  inputs',
  ...
}:
let
  lib = { };
in
{
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
      _module.args.pkgs = import inputs'.nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      # For 'nix fmt'
      formatter = pkgs.nixpkgs-fmt;
    };
  flake = {
    inherit lib;
  };
}
