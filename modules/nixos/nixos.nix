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

    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    system.stateVersion = "24.11";
  };
}
