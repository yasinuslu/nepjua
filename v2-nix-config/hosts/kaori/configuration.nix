# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{...}:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

    myNixOS = {
      bundles.general-desktop.enable = true;
      bundles.users.enable = true;
      
      features.gnome.enable = true;
      features.xserver-nvidia.enable = true;

      home-users = {
        nepjua = {
          userConfig = ./nepjua.nix;
          userSettings = {
            extraGroups = ["docker" "libvirtd" "networkmanager" "wheel" "adbusers"];
          };
        };
      };
    };
}

