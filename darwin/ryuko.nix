{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./common.nix
  ];

  users.users.musu.home = "/Users/musu";
  users.users.musu.shell = pkgs.fish;

  networking.hostName = "ryuko";
  networking.computerName = "ryuko";
}
