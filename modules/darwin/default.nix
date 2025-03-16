# This is your nix-darwin configuration.
# For home configuration, see /modules/home/*
{
  flake,
  pkgs,
  lib,
  ...
}:

let
  inherit (flake) inputs;
in
{
  # Use TouchID for `sudo` authentication
  security.pam.services.sudo_local.touchIdAuth = true;
}
