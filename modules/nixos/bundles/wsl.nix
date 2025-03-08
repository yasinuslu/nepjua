{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    inputs.nixos-wsl.nixosModules.wsl
    {
      wsl.enable = true;
    }
  ];

  myNixOS = {
    networking.enable = lib.mkOverride 100 true;
    nix-ld.enable = lib.mkOverride 100 true;
    common-base.enable = lib.mkOverride 100 true;
    home-manager.enable = lib.mkOverride 100 true;
    nix-index.enable = lib.mkOverride 100 true;

    hoppscotch.enable = lib.mkOverride 150 false;
    gaming.enable = lib.mkOverride 150 false;
    networking.qos.enable = lib.mkOverride 100 false;
    _1password.enable = lib.mkOverride 150 false;
    appimage.enable = lib.mkOverride 150 false;
    automount.enable = lib.mkOverride 100 false;
    cloudflare-warp.enable = lib.mkOverride 100 false;
    docker.enable = lib.mkOverride 100 false;
    exfat.enable = lib.mkOverride 100 false;
    flatpak.enable = lib.mkOverride 150 false;
    gnome-adaptive-theme.enable = lib.mkOverride 150 false;
    gnome-autologin.enable = lib.mkOverride 150 false;
    gnome.enable = lib.mkOverride 150 false;
    gparted.enable = lib.mkOverride 150 false;
    lorri.enable = lib.mkOverride 100 false;
    mullvad-vpn.enable = lib.mkOverride 150 false;
    ntfs.enable = lib.mkOverride 100 false;
    podman.enable = lib.mkOverride 100 false;
    proxmox-host.enable = lib.mkOverride 100 false;
    qemu-guest.enable = lib.mkOverride 100 false;
    spice-guest.enable = lib.mkOverride 100 false;
    spice-viewer.enable = lib.mkOverride 100 false;
    ssh-server.enable = lib.mkOverride 100 false;
    systemd-boot.enable = lib.mkOverride 100 false;
    tailscale.enable = lib.mkOverride 100 false;
    xserver.enable = lib.mkOverride 150 false;
    vmware-guest.enable = lib.mkOverride 100 false;
    zfs.enable = lib.mkOverride 100 false;
    zoom-us.enable = lib.mkOverride 150 false;
  };
}
