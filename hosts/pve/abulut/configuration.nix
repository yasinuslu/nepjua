# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{ lib, ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "pve-abulut";
  networking.firewall.enable = false;

  # Explicitly disable NetworkManager and enable systemd-networkd
  networking.networkmanager.enable = lib.mkForce false;
  networking.useNetworkd = true;

  # Use systemd-networkd with matching
  systemd.network = {
    enable = true;
    networks."10-virtio" = {
      matchConfig.Type = "ether";
      matchConfig.Driver = "virtio_net";
      networkConfig = {
        Address = "192.168.0.12/24";
        Gateway = "192.168.0.1";
        DNS = "1.1.1.1 8.8.8.8";
      };
    };
  };

  # Disable DHCP globally
  networking.useDHCP = lib.mkForce false;

  myNixOS = {
    mainUser = "abulut";

    gaming.enable = false;
    podman.enable = false;
    xserver-nvidia.enable = false;
    systemd-boot.enable = false;

    users = {
      abulut = {
        userConfig =
          { ... }:
          {
            programs.git.userName = "Abdurrahim Bulut";
            programs.git.userEmail = "bulut.send@gmail.com";

            myHomeManager.docker.enable = false;
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
