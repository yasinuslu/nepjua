{ lib, ... }:
{
  myNixOS = {
    bundles._100-base.enable = lib.mkOverride 200 true;
    bundles._150-base-desktop.enable = lib.mkOverride 200 true;

    _1password.enable = lib.mkOverride 200 true;
    appimage.enable = lib.mkOverride 200 true;
    autologin.enable = lib.mkOverride 200 true;
    flatpak.enable = lib.mkOverride 200 true;
    zoom-us.enable = lib.mkOverride 200 true;
  };
}
