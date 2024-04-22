# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{...}: {
  networking.hostName = "chained";
  networking.computerName = "Yasin Mac";

  myNixOS = {
    bundles.darwin-desktop.enable = true;

    users = {
      nepjua = {
        userConfig = {...}: {
          programs.git.userName = "Yasin Uslu";
          programs.git.userEmail = "nepjua@gmail.com";
        };
        userSettings = {};
      };
    };
  };
}
