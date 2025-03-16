# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{ ... }:
{
  networking.hostName = "chained";
  networking.computerName = "Yasin Uslu MC";

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
