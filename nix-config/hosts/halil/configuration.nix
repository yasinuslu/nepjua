# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{...}: {
  networking.hostName = "halil-mbp";
  networking.computerName = "Halils-MBP";

  myNixOS = {
    bundles.darwin-desktop.enable = true;

    users = {
      halil = {
        userConfig = {...}: {
          programs.git.userName = "Halil Ertekin";
          programs.git.userEmail = "halil@ertekin.me";
        };
        userSettings = {};
      };
    };
  };
}
