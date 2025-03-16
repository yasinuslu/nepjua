{ config, lib, ... }:
let
  cfg = config.my.nixos;
in
{
  options = {
    my.nixos = {
      enable = lib.mkOption {
        default = true;
        example = true;
        description = "Whether to enable nixos.";
        type = lib.types.bool;
      };
    };
  };

  config = lib.mkIf cfg.enable {
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

    system.stateVersion = "24.11";
  };
}
