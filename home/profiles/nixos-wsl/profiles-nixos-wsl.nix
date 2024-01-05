{
  inputs,
  pkgs,
  config,
  ...
}: {
  imports = [
    ../../src/cli/playwright.nix
  ];

  home.extraPaths = ["$HOME/.rd/bin"];
}
