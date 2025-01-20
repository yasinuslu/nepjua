{ lib, ... }:
{
  myHomeManager = {
    bundles._100-common-base.enable = lib.mkOverride 125 true;
    # darwin = {
    #   colima.enable = lib.mkOverride 125 true;
    #   docker.enable = lib.mkOverride 125 true;
    #   homebrew-path.enable = lib.mkOverride 125 true;
    # };
  };
}
