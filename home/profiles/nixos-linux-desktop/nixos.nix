# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{inputs, ...}: {
  imports = [
    ../__enter.nix
    ../cli/__enter.nix
    ../cli/__exit.nix
    ../desktop/nixos.nix
    ../__exit.nix
  ];

  home = {
    username = "nepjua";
    homeDirectory = "/home/nepjua";
  };

  programs.vscode = {
    enable = true;
  };
}
