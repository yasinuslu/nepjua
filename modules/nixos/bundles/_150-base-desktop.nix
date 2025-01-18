{
  lib,
  ...
}:
{
  myNixOS = {
    bundles._100-base.enable = lib.mkOverride 150 true;

    graphics-base.enable = lib.mkOverride 150 true;
  };
}
