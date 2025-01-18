{
  lib,
  ...
}:
{
  myNixOS = {
    minimal-desktop.enable = lib.mkOverride 200 true;
  };
}
