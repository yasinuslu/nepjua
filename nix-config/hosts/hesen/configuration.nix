# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{...}: {
  networking.hostName = "Hesens-MacBook-Pro";
  networking.computerName = "Hesens-MacBook-Pro";

  myNixOS = {
    bundles.darwin-desktop.enable = true;
    app-vlc.enable = false;

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
