# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{ pkgs, ... }:
{
  networking.hostName = "chained";
  networking.computerName = "Yasin Uslu MC";

  security.pki.certificateFiles = [
    "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
    "/Users/yahmet/code/nepjua/.generated/extra_certs.crt"
  ];

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
