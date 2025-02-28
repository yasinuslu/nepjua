# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{ lib, ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "nari";
  networking.hostId = "b141a362";
  networking.firewall.enable = false;

  myNixOS = {
    mainUser = "nepjua";

    bundles.minimal.enable = lib.mkOverride 500 true;
    bundles.gnome.enable = lib.mkOverride 500 true;

    # FIXME: Find a way to make this work
    cloudflare-warp.enable = lib.mkOverride 500 false;

    # For enabling Gnome features
    _1password.enable = lib.mkForce true;
    appimage.enable = lib.mkForce true;
    gnome-adaptive-theme.enable = lib.mkForce true;
    gnome-autologin.enable = lib.mkForce true;
    gnome.enable = lib.mkForce true;
    gparted.enable = lib.mkForce true;
    mullvad-vpn.enable = lib.mkForce true;
    spice-viewer.enable = lib.mkForce true;
    xserver.enable = lib.mkForce true;
    xserver.amdgpu.enable = lib.mkForce false;
    xserver.nvidia.enable = lib.mkForce true;

    # Specific for pve-guests
    spice-guest.enable = lib.mkForce false;
    qemu-guest.enable = lib.mkForce false;
    vmware-guest.enable = lib.mkForce true;

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
            "spice"
          ];
        };
      };
    };
  };
}
