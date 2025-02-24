# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{ lib, ... }:
{
  imports = [
    ./custom-hardware-configuration.nix
  ];

  networking.hostName = "kaori";
  networking.hostId = "5bf9bcae";
  networking.firewall.enable = false;

  services.xserver.videoDrivers = [
    "amdgpu"
    "nvidia"
  ];

  boot.blacklistedKernelModules = [
    "nouveau"
    "nvidia"
    "nvidia_drm"
    "nvidia_uvm"
    "nvidia_modeset"
  ];

  # networking.interfaces.eno1 = {
  #   useDHCP = true;
  #   mtu = 1500;
  #   wakeOnLan.enable = true;
  #   # linkSpeed = "1000";  # This sets the link speed to 1Gbps
  # };

  myNixOS = {
    mainUser = "nepjua";
    bundles.minimal.enable = lib.mkOverride 500 true;
    bundles.gnome.enable = lib.mkOverride 500 true;

    # FIXME: Find a way to make this work
    cloudflare-warp.enable = lib.mkOverride 500 false;

    # This is weird
    _1password.enable = lib.mkForce true;
    appimage.enable = lib.mkForce true;
    gnome-adaptive-theme.enable = lib.mkForce true;
    gnome-autologin.enable = lib.mkForce true;
    gnome.enable = lib.mkForce true;
    gparted.enable = lib.mkForce true;
    mullvad-vpn.enable = lib.mkForce true;
    spice-viewer.enable = lib.mkForce true;
    xserver.enable = lib.mkForce true;
    xserver.amdgpu.enable = lib.mkForce true;
    xserver.nvidia.enable = lib.mkForce false;

    # VM Host
    proxmox-host.enable = lib.mkForce true;
    zfs.enable = lib.mkForce true;

    users = {
      nepjua = {
        userConfig =
          { ... }:
          {
            programs.git.userName = "Yasin Uslu";
            programs.git.userEmail = "nepjua@gmail.com";

            myHomeManager = {
              linux.cloudflare.enable = false;
              docker.enable = false;

              # We are in winter, so sun doesn't bother me that much these days
              linux.darkman.enable = false;
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
