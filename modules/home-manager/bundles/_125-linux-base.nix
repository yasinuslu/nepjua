{ lib, ... }:
{
  myHomeManager = {
    bundles._100-common-base.enable = lib.mkOverride 125 true;
    linux = {
      base.enable = lib.mkOverride 125 true;
    };
  };
}
