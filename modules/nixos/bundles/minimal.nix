{
  lib,
  ...
}:
{
  myNixOS = {
    bundles.general-desktop.enable = lib.mkForce false;

    flatpak.enable = lib.mkForce false;
    appimage.enable = lib.mkForce false;
    xserver-nvidia.enable = lib.mkForce false;
    gaming.enable = lib.mkForce false;
  };
}
