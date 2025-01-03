{
  config,
  lib,
  ...
}: let
  cfg = config.myNixOS.bundles.proxmox-guest;
in {
  imports = lib.mkIf cfg.enable [
    ./hardware-configuration.nix
    ./proxmox-guest.nix
  ];
}
