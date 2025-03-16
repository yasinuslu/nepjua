{
  config,
  lib,
  pkgs,
  ...
}:
{
  myNixOS = {
    gaming.enable = lib.mkOverride 150 false;
    hoppscotch.enable = lib.mkOverride 150 false;
    networking.enable = lib.mkOverride 100 true;

    # FIXME: This either never worked or temporarily broken
    networking.qos.enable = lib.mkOverride 100 false;
    nix-ld.enable = lib.mkOverride 100 true;

    _1password.enable = lib.mkOverride 150 false;
    appimage.enable = lib.mkOverride 150 false;
    automount.enable = lib.mkOverride 100 true;
    cloudflare-warp.enable = lib.mkOverride 100 true;
    common-base.enable = lib.mkOverride 100 true;
    docker.enable = lib.mkOverride 100 false;
    exfat.enable = lib.mkOverride 100 true;
    flatpak.enable = lib.mkOverride 150 false;
    gnome-adaptive-theme.enable = lib.mkOverride 150 false;
    gnome-autologin.enable = lib.mkOverride 150 false;
    gnome.enable = lib.mkOverride 150 false;
    gparted.enable = lib.mkOverride 150 false;
    # grub.enable = lib.mkOverride 150 false;
    home-manager.enable = lib.mkOverride 100 true;
    lorri.enable = lib.mkOverride 100 true;
    mullvad-vpn.enable = lib.mkOverride 150 false;
    nix-index.enable = lib.mkOverride 100 true;
    ntfs.enable = lib.mkOverride 100 true;
    podman.enable = lib.mkOverride 100 true;
    proxmox-host.enable = lib.mkOverride 100 false;
    qemu-guest.enable = lib.mkOverride 100 false;
    spice-guest.enable = lib.mkOverride 100 false;
    spice-viewer.enable = lib.mkOverride 100 false;
    ssh-server.enable = lib.mkOverride 100 true;
    systemd-boot.enable = lib.mkOverride 100 true;
    tailscale.enable = lib.mkOverride 100 false;
    xserver.enable = lib.mkOverride 150 false;
    vmware-guest.enable = lib.mkOverride 100 false;
    zfs.enable = lib.mkOverride 100 false;
    zoom-us.enable = lib.mkOverride 150 false;
  };
}
