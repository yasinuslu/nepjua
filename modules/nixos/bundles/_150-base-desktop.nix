{
  lib,
  ...
}:
{
  myNixOS = {
    graphics-base.enable = lib.mkOverride 150 true;
  };
}
