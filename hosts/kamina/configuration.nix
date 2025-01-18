# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{ ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "kamina";

  myNixOS = {
    mainUser = "nepjua";
    bundles._200-desktop-minimal.enable = true;

    users = {
      nepjua = {
        userConfig =
          { ... }:
          {
            programs.git.userName = "Yasin Uslu";
            programs.git.userEmail = "nepjua@gmail.com";

            myHomeManager = {
              bundles._200-linux-desktop-gnome.enable = true;
            };
          };

        userSettings = {
          extraGroups = [
            "networkmanager"
            "wheel"
            "adbusers"
            "docker"
            "lxd"
            "kvm"
            "libvirtd"
            "spice"
          ];
        };
      };
    };
  };
}
