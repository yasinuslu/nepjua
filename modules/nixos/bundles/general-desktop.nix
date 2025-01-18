{ lib, ... }:
{
  myNixOS = {
    qemu-guest.enable = lib.mkDefault false;
    spice-guest.enable = lib.mkDefault false;
    gaming.enable = lib.mkDefault false;
    podman.enable = lib.mkDefault false;
  };

  # NetworkManager configuration
  networking.networkmanager.enable = lib.mkDefault true;
  systemd.services.NetworkManager-wait-online.enable = lib.mkDefault false;
  networking.networkmanager.wifi.powersave = lib.mkDefault false;
}
