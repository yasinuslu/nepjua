{inputs, pkgs, ...}: {
  imports = [
    # If you want to use home-manager modules from other flakes (such as nix-colors):
    inputs.nix-colors.homeManagerModule
  ];
}
