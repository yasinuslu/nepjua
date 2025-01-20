# A simple hello module to test our module system
localFlake:
{
  config,
  lib,
  pkgs,
  ...
}:
{
  options = { };

  config = {
    flake = {
      testingIfConfigIsSet = config.myFlake.nixos.features.hello.enable;
    };
  };
}
