{ ... }:
{
  myNixOS = {
    qemu-guest.enable = false;
    spice-guest.enable = false;
    gaming.enable = false;
    podman.enable = false;
  };

  # # NetworkManager configuration
  # networking.networkmanager.enable = false;
  # systemd.services.NetworkManager-wait-online.enable = false;
  # networking.networkmanager.wifi.powersave = false;
}
