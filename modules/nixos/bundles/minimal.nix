{
  lib,
  ...
}:
{
  myNixOS = {
    bundles.general-desktop.enable = lib.mkOverride 500 false;

    flatpak.enable = lib.mkOverride 500 false;
    appimage.enable = lib.mkOverride 500 false;
    xserver-nvidia.enable = lib.mkOverride 500 false;
    gaming.enable = lib.mkOverride 500 false;
    qemu-guest.enable = lib.mkOverride 500 false;
    spice-guest.enable = lib.mkOverride 500 false;
  };
}
