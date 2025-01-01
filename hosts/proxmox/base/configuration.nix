# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{...}: {
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "proxmox-base";
  networking.firewall.enable = false;

  myNixOS = {
    mainUser = "proxmox";
    bundles.proxmox-guest.enable = true;
    bundles.general-desktop.enable = false;
    nix-ld.enable = false;

    # Enable SPICE guest features
    spice.guest.enable = true;

    users = {
      proxmox = {
        userConfig = {...}: {
          programs.git.userName = "Proxmox";
          programs.git.userEmail = "proxmox@localhost";

          myHomeManager.docker.enable = false;
        };

        userSettings = {
          extraGroups = ["networkmanager" "wheel" "adbusers" "docker" "lxd" "kvm" "libvirtd" "spice"];
        };
      };
    };
  };
}
