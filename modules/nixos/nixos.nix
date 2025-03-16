{ config, lib, ... }:
let
  cfg = config.my.nixos;
in
{
  options = {
    my.nixos = {
      enable = lib.mkEnableOption "nixos";
    };
  };

  config = lib.mkMerge [
    {
      my.nixos.enable = lib.mkDefault true;
    }
    (lib.mkIf cfg.enable {
      nix.settings = {
        # Enable flakes and new 'nix' command
        experimental-features = "nix-command flakes auto-allocate-uids";
        accept-flake-config = true;
        auto-allocate-uids = true;
        substituters = [ ];
        trusted-substituters = [ ];
        trusted-public-keys = [ ];
      };

      nix.optimise = {
        automatic = true;
        dates = [ "03:45" ]; # Runs daily at 3:45 AM
      };

      nixpkgs.config.allowUnfree = true;
      nixpkgs.config.allowUnsupportedSystem = false;

      system.stateVersion = lib.mkDefault "24.11";
    })
  ];
}
