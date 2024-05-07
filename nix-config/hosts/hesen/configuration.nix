# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{...}: {
  networking.hostName = "MacBook-Pro-Hesen";
  networking.computerName = "MacBook-Pro-Hesen";

  myNixOS = {
    bundles.darwin-desktop.enable = true;

    users = {
      hesenaliyev = {
        userConfig = {...}: {
          programs.git.userName = "hesenaliyev14";
          programs.git.userEmail = "hesenaliyevis@gmail.com";
        };
        userSettings = {};
      };
    };
  };
}
