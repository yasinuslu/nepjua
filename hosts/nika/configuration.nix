# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{ lib, ... }:
{
  networking.hostName = "nika";
  networking.hostId = "5f52d94";
  networking.firewall.enable = false;


  myNixOS = {
    mainUser = "nepjua";
    bundles.minimal.enable = lib.mkOverride 500 true;

    # FIXME: Find a way to make this work
    cloudflare-warp.enable = lib.mkOverride 500 false;

    # Enable/Disable GNOME on Host easily
    # We will have to put up with this until the VM becomes rock-solid
    _1password.enable = lib.mkForce false;
    appimage.enable = lib.mkForce false;
    gnome-adaptive-theme.enable = lib.mkForce false;
    gnome-autologin.enable = lib.mkForce false;
    gnome.enable = lib.mkForce false;
    gparted.enable = lib.mkForce false;
    mullvad-vpn.enable = lib.mkForce false;
    spice-viewer.enable = lib.mkForce false;
    xserver.enable = lib.mkForce false;
    xserver.amdgpu.enable = lib.mkForce false;
    xserver.nvidia.enable = lib.mkForce false;
    
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
