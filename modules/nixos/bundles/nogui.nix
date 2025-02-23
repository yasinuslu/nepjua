{
  config,
  lib,
  pkgs,
  ...
}:
{
  myNixOS = {
    bundles.general-desktop.enable = lib.mkForce false;

    gaming.enable = lib.mkForce false;
    hoppscotch.enable = lib.mkForce false;
    networking.enable = lib.mkDefault true;
    nix-ld.enable = lib.mkDefault true;

    _1password.enable = lib.mkForce false;
    appimage.enable = lib.mkForce false;
    automount.enable = lib.mkDefault true;
    cloudflare-warp.enable = lib.mkDefault true;
    common-base.enable = lib.mkDefault true;
    docker.enable = lib.mkDefault true;
    exfat.enable = lib.mkDefault true;
    flatpak.enable = lib.mkForce false;
    gnome-adaptive-theme.enable = lib.mkForce false;
    gnome-autologin.enable = lib.mkForce false;
    gnome.enable = lib.mkForce false;
    gparted.enable = lib.mkForce false;
    # grub.enable = lib.mkForce false;
    home-manager.enable = lib.mkDefault true;
    lorri.enable = lib.mkDefault true;
    mullvad-vpn.enable = lib.mkForce false;
    nix-index.enable = lib.mkDefault true;
    nixos-base.enable = lib.mkDefault true;
    ntfs.enable = lib.mkDefault true;
    podman.enable = lib.mkDefault true;
    proxmox-host.enable = lib.mkDefault true;
    qemu-guest.enable = lib.mkDefault false;
    spice-guest.enable = lib.mkDefault false;
    spice-viewer.enable = lib.mkDefault false;
    ssh-server.enable = lib.mkDefault true;
    systemd-boot.enable = lib.mkDefault true;
    tailscale.enable = lib.mkDefault false;
    xserver.enable = lib.mkForce false;
    zfs.enable = lib.mkDefault true;
    zoom-us.enable = lib.mkForce false;
  };
}
