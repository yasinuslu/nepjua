localFlake:
{ lib, ... }:
let
  mkLinuxConfig =
    { name, ... }:
    lib.nixosSystem {
      inherit name;
      modules = [
        localFlake.nixosModules.default
      ];
    };
in
{
  flake = {
    nixosConfigurations = {
      nika = mkLinuxConfig { name = "nika"; };
    };
  };
}
