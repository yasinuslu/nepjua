{
  lib,
  ...
}:
{
  myNixOS = {
    bundles._100-base.enable = lib.mkOverride 150 true;

    desktop-base.enable = lib.mkOverride 150 true;
  };
}
