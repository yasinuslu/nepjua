# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{lib, ...}: {
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "pve-nepjua";
  networking.firewall.enable = false;

  # Explicitly disable NetworkManager and enable systemd-networkd
  networking.networkmanager.enable = lib.mkForce false;
  networking.useNetworkd = true;

  # Static IP configuration
  networking = {
    useDHCP = lib.mkForce false;
    interfaces.ens18 = {
      useDHCP = false;
      ipv4.addresses = [
        {
          address = "192.168.0.10";
          prefixLength = 24;
        }
      ];
    };
    defaultGateway = "192.168.0.1";
    nameservers = ["1.1.1.1" "8.8.8.8"];
  };

  myNixOS = {
    mainUser = "nepjua";

    gaming.enable = false;
    podman.enable = false;
    xserver-nvidia.enable = false;
    systemd-boot.enable = false;

    users = {
      nepjua = {
        userConfig = {...}: {
          programs.git.userName = "Yasin Uslu";
          programs.git.userEmail = "nepjua@gmail.com";

          myHomeManager.docker.enable = false;
        };

        userSettings = {
          extraGroups = ["networkmanager" "wheel" "adbusers" "docker" "lxd" "kvm" "libvirtd" "spice"];
        };
      };
    };
  };
}
