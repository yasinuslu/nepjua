{ lib, ... }:
{
  myNixOS = {
    qemu-guest.enable = lib.mkOverride 500 false;
    spice-guest.enable = lib.mkOverride 500 false;
    gaming.enable = lib.mkOverride 500 false;
    podman.enable = lib.mkOverride 500 false;
  };

  # NetworkManager configuration
  networking.networkmanager.enable = lib.mkOverride 500 true;
  systemd.services.NetworkManager-wait-online.enable = lib.mkOverride 500 false;
  networking.networkmanager.wifi.powersave = lib.mkOverride 500 false;
}
