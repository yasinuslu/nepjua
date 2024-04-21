{lib, ...}: {
  config.myHomeManager.minimal-home.enable = lib.mkDefault true;
  config.myHomeManager.fish.enable = lib.mkDefault true;
}
