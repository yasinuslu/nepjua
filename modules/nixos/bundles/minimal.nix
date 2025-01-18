{
  lib,
  ...
}:
{
  myNixOS = {
    bundles.general-desktop.enable = lib.mkDefault false;

    flatpak.enable = lib.mkDefault false;
    appimage.enable = lib.mkDefault false;
    xserver-nvidia.enable = lib.mkDefault false;
    gaming.enable = lib.mkDefault false;
    qemu-guest.enable = lib.mkDefault false;
    spice-guest.enable = lib.mkDefault false;
  };
}
