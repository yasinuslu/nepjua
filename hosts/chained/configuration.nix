# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{
  pkgs,
  lib,
  config,
  ...
}:
{
  networking.hostName = "chained";
  networking.computerName = "Yasin Uslu MC";

  # Secrets are now defined centrally in modules/darwin/features/sops.nix
  # They will be available at:
  # - config.sops.secrets."hosts/chained/username".path
  # - config.sops.secrets."hosts/chained/certificates".path

  myDarwin = {
    bundles.darwin-desktop.enable = true;

    homebrew-extra.enable = false;

    users = {
      yahmet = {
        userConfig =
          { ... }:
          {
            programs.git.userName = "TO BE SET";
            programs.git.userEmail = "to-be-set@example.com";

            myHomeManager = {
              # impure-node.enable = false;
            };
          };
        userSettings = { };
      };
    };
  };
}
