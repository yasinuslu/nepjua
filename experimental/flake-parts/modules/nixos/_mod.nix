localFlake:
{ ... }:
{
  flake = {
    features = localFlake.importApply ./features/_mod.nix localFlake;
  };
}
