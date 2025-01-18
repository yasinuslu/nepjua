{ lib, ... }:
{
  myNixOS = {
    _1password.enable = lib.mkOverride 200 true;
    appimage.enable = lib.mkOverride 200 true;
    autologin.enable = lib.mkOverride 200 true;
    flatpak.enable = lib.mkOverride 200 true;
    zoom-us.enable = lib.mkOverride 200 true;
  };
}
