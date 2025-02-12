# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{ ... }:
{
  imports = [
    ./custom-hardware-configuration.nix
  ];

  networking.hostName = "kaori";
  networking.hostId = "5bf9bcae";
  networking.firewall.enable = false;

  # networking.interfaces.eno1 = {
  #   useDHCP = true;
  #   mtu = 1500;
  #   wakeOnLan.enable = true;
  #   # linkSpeed = "1000";  # This sets the link speed to 1Gbps
  # };
  fileSystems."/tank/vm" = {
    device = "tank/vm";
    fsType = "zfs";
    options = [ "zfsutil" ];
  };

  fileSystems."/tank/data" = {
    device = "tank/data";
    fsType = "zfs";
    options = [ "zfsutil" ];
  };

  # Remove this mount since we're moving it to /nix/store
  fileSystems."/tank/nixstore" = {
    device = "tank/nixstore";
    fsType = "zfs";
    options = [ "zfsutil" ];
  };

  # Keep this one
  fileSystems."/nix/store" = {
    device = "tank/nixstore";
    fsType = "zfs";
    options = [ "zfsutil" ];
    neededForBoot = true;
  };

  myNixOS = {
    mainUser = "nepjua";
    bundles.general-desktop.enable = true;
    grub.enable = false;

    zoom-us.enable = false;
    xserver-nvidia.enable = false;
    xserver-radeon.enable = true;

    users = {
      nepjua = {
        userConfig =
          { ... }:
          {
            programs.git.userName = "Yasin Uslu";
            programs.git.userEmail = "nepjua@gmail.com";

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
          ];
        };
      };
    };
  };
}
