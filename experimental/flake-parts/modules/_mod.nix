localFlake:
{ ... }:
{
  flake = {
    nixos = localFlake.importApply ./nixos/_mod.nix localFlake;
  };
}
