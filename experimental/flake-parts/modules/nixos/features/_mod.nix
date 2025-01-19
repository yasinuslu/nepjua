localFlake:
{ ... }:
{
  flake = {
    desktop = localFlake.importApply ./desktop/_mod.nix localFlake;
  };
}
