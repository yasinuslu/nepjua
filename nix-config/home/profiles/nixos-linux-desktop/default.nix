{
  lib,
  config,
  pkgs,
}: {
  imports = [
    ../../src/extensions/extra-paths/__enter.nix
    ../../profiles/minimal

    ../../src/desktop/__enter.nix
    ../../src/desktop/nixos.nix
    ../../src/desktop/__exit.nix

    ../../src/extensions/extra-paths/__exit.nix
  ];

  home = {
    username = "nepjua";
    homeDirectory = "/home/nepjua";
  };

  programs.vscode = {
    enable = true;
  };
}
