{
  inputs,
  lib,
  config,
  ...
}: {
  options.home.extraPaths = lib.mkOption {
    type = with lib.types; listOf str;
    default = [];
    description = "Extra paths to add to the PATH variable.";
  };

  imports = [
    # If you want to use home-manager modules from other flakes (such as nix-colors):
    inputs.nix-colors.homeManagerModule
  ];

  programs = {
    java.enable = true;
    gh.enable = true;
    direnv.enable = true;
    direnv.nix-direnv.enable = true;
  };

  home.sessionVariables.PATH = lib.concatStringsSep ":" (
    ["$PATH"] ++ config.home.extraPaths
  );
}
