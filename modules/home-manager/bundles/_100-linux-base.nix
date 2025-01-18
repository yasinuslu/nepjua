{ lib, ... }:
{
  myHomeManager = {
    bundles._100-common-base.enable = lib.mkOverride 100 true;
    linux = {
      base.enable = lib.mkOverride 100 true;
    };
  };
}
