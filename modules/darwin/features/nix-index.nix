{ inputs, ... }:
{
  # FIXME: This no longer works with darwin
  # imports = [
  #   inputs.nix-index-database.nixosModules.nix-index
  #   ({...}: {
  #     programs.nix-index-database.comma.enable = true;
  #     programs.nix-index.enable = true;
  #     programs.command-not-found.enable = true;
  #   })
  # ];
}
