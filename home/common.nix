{
  inputs,
  pkgs,
  ...
}: {
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
}
