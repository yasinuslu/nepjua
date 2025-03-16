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
  options = homeFlake.mkOption { inherit lib pkgs; };
  config = homeFlake.mkConfig { inherit lib pkgs config; };
}
