{
  inputs,
  pkgs,
  config,
  ...
}: {
  imports = [
    ../../src/cli/packages.nix
  ];

  home.extraPaths = ["$HOME/.rd/bin"];
}
