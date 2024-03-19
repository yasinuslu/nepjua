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
    ./gui-apps.nix
    ./keyboard.nix
  ];

  users.users.yahmet.home = "/Users/yahmet";
  users.users.yahmet.shell = pkgs.fish;

  networking.hostName = "chained";
  networking.computerName = "Yasin MC";
}
