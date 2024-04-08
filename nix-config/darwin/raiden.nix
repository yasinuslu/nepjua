{
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    ./common.nix
    ./apps/alt-tab.nix
    ./apps/homebrew-minimal.nix
    ./apps/homebrew-extra.nix
    ./gui-apps.nix
    ./keyboard.nix
  ];

  users.users.nepjua.home = "/Users/nepjua";
  users.users.nepjua.shell = pkgs.fish;

  users.users.musu.home = "/Users/musu";
  users.users.musu.shell = pkgs.fish;

  networking.hostName = "raiden";
  networking.computerName = "Raiden";
}
