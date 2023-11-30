{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./common.nix
  ];

  users.users.nepjua.home = "/Users/nepjua";
  users.users.nepjua.shell = pkgs.fish;

  # users.users.yasinuslu-mc.home = "/Users/yasinuslu-mc";
  # users.users.yasinuslu-mc.shell = pkgs.fish;

  networking.hostName = "raiden";
  networking.computerName = "raiden";
}
