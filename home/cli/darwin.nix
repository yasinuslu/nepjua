{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./common.nix
  ];

  home.extraPaths = ["$HOME/.rd/bin"];
}
