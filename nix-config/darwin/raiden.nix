{
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    ./common.nix
    ./apps/alt-tab.nix
    ./apps/homebrew.nix
    ./gui-apps.nix
    ./keyboard.nix
  ];

  services.spotifyd.enable = true;

  users.users.nepjua.home = "/Users/nepjua";
  users.users.nepjua.shell = pkgs.fish;

  networking.hostName = "raiden";
  networking.computerName = "raiden";
}
