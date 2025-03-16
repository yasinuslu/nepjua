{ lib, config, ... }:
let
  cfg = config.my.proxmox;
in
{
  options = {
    my.proxmox = {
      enable = lib.mkEnableOption "proxmox";
    };
  };

  config = lib.mkIf cfg.enable {
    nix.settings = {
      substituters = [
        "https://cache.saumon.network/proxmox-nixos"
      ];
      trusted-substituters = [
        "https://cache.saumon.network/proxmox-nixos"
      ];
      trusted-public-keys = [
        "proxmox-nixos:nveXDuVVhFDRFx8Dn19f1WDEaNRJjPrF2CPD2D+m1ys="
      ];
    };
  };
}
