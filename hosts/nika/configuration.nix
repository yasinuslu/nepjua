# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{ lib, pkgs, ... }:
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
                desktop.enable = lib.mkForce false;
                cloudflare.enable = lib.mkForce false;
                darkman.enable = lib.mkForce false;
                terminal.enable = lib.mkForce false;
                _1password.enable = lib.mkForce false;
                gnome.enable = lib.mkForce false;
                jetbrains.enable = lib.mkForce false;
                linux-editor.enable = lib.mkForce false;
                wsl-home.enable = lib.mkForce true;
              };

              docker.enable = lib.mkForce false;
            };
            
            # FIXME: Don't know why this fixes dconf errors in WSL
            # But let's keep it here for now
            dconf.enable = lib.mkForce false;
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
