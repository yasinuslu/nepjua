{inputs, ...}: {
  imports = [
    inputs.home-manager.darwinModules.home-manager
    ./users.nix
  ];
}
