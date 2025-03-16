{
  flake,
  lib,
  pkgs,
  config,
  ...
}:
let
  homeFlake = flake.my.home;
in
{
  options = {
    my.home = homeFlake.mkOption { inherit lib pkgs; };
  };

  config = homeFlake.mkConfig { inherit lib pkgs config; };
}
