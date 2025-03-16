# Top-level flake glue to get our configuration working
{ inputs, ... }:

{
  imports = [
    inputs.flake-root.flakeModule
    inputs.nixos-unified.flakeModules.default
    inputs.nixos-unified.flakeModules.autoWire
  ];
  perSystem =
    {
      self',
      pkgs,
      system,
      ...
    }:
    {
      # This sets `pkgs` to a nixpkgs with allowUnfree option set.
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      # For 'nix fmt'
      formatter = pkgs.nixpkgs-fmt;

      # Enables 'nix run' to activate.
      packages.default = self'.packages.activate;
    };
}
