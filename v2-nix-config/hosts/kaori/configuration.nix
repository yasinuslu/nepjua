# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{...}: {
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "kaori";

  myNixOS = {
    bundles.general-desktop.enable = true;

    home-users = {
      nepjua = {
        userConfig = {...}: {
          programs.git.userName = "Yasin Uslu";
          programs.git.userEmail = "nepjua@gmail.com";

          myHomeManager = {
            bundles.tui.enable = true;
            bundles.gui.enable = true;
          };
        };
        userSettings = {
          extraGroups = ["docker" "libvirtd" "networkmanager" "wheel" "adbusers"];
        };
      };
    };
  };
}
