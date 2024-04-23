set shell := ["fish", "-c"]

repl:
  nix repl --show-trace

# Open a nix shell with the nixpkgs
repl-nixpkgs:
  nix repl -f flake:nixpkgs

build-verbose-no-cache host="kaori":
  nixos-rebuild build --flake .#{{host}} --option eval-cache false --show-trace --print-build-logs --verbose --impure

build-verbose host="kaori":
  nixos-rebuild build --flake .#{{host}} --show-trace --print-build-logs --verbose --impure

switch host="kaori":
  sudo nixos-rebuild switch --flake .#{{host}} --impure

darwin-switch host="joyboy":
  darwin-rebuild switch --flake .#{{host}}

darwin-debug host="joyboy":
  darwin-rebuild build --flake .#{{host}} --show-trace --option eval-cache false

update-dconf:
  dconf dump "/" | nix run nixpkgs#dconf2nix > ./modules/home-manager/features-gui/gnome/dconf.nix

up:
  nix flake update
