{inputs, ...}: {
  imports = [
    inputs.home-manager.nixosModules.home-manager
    ./users.nix
  ];
}
