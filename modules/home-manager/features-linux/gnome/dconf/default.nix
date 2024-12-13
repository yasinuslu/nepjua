{ lib, ... }:

{
  imports = [
    ./interface.nix
    ./input.nix
    ./wm.nix
    ./mutter.nix
    ./shell.nix
    ./power.nix
    ./keybindings.nix
    ./background.nix
  ];
}
