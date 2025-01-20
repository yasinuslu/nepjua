{
  lib,
  ...
}:
{
  myNixOS = {
    bundles._100-base.enable = lib.mkOverride 200 true;
    bundles._150-base-desktop.enable = lib.mkOverride 200 true;

    minimal-desktop.enable = lib.mkOverride 200 true;
  };
}
