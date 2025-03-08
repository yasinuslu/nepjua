# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{ lib, ... }:
{
  networking.hostName = "nika";
  networking.hostId = "e5fda3f2";
  networking.firewall.enable = false;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  myNixOS = {
    mainUser = "nepjua";
    bundles.wsl.enable = lib.mkOverride 500 true;
    
    users = {
      nepjua = {
        userConfig =
          { ... }:
          {
            programs.git.userName = "Yasin Uslu";
            programs.git.userEmail = "nepjua@gmail.com";

            myHomeManager = {
              linux = {
                desktop.enable = false;
                cloudflare.enable = false;
                darkman.enable = false;
                terminal.enable = false;
                _1password.enable = false;
                gnome.enable = false;
                jetbrains.enable = false;
                linux-editor.enable = false;
              };

              docker.enable = false;
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
          ];
        };
      };
    };
  };
}
