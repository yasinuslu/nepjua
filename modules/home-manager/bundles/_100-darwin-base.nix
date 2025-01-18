{ lib, ... }:
{
  myHomeManager = {
    bundles._100-common-base.enable = lib.mkOverride 100 true;
    darwin = {
      colima.enable = lib.mkOverride 100 true;
      docker.enable = lib.mkOverride 100 true;
      homebrew-path.enable = lib.mkOverride 100 true;
    };
  };
}
