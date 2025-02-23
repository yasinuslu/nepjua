{
  config,
  lib,
  pkgs,
  ...
}:
{
  myNixOS = {
    _1password.enable = lib.mkOverride 200 true;
    appimage.enable = lib.mkOverride 200 true;
    gnome-adaptive-theme.enable = lib.mkOverride 200 true;
    gnome-autologin.enable = lib.mkOverride 200 true;
    gnome.enable = lib.mkOverride 200 true;
    gparted.enable = lib.mkOverride 200 true;
    mullvad-vpn.enable = lib.mkOverride 200 true;
    spice-viewer.enable = lib.mkOverride 200 true;
    xserver.enable = lib.mkOverride 200 true;
    xserver.nvidia.enable = lib.mkOverride 200 false;
  };
}
