{
  lib,
  ...
}:
{
  myNixOS = {
    common-base.enable = lib.mkOverride 100 true;
    exfat.enable = lib.mkOverride 100 true;
    home-manager.enable = lib.mkOverride 100 true;
    lorri.enable = lib.mkOverride 100 true;
    networking.enable = lib.mkOverride 100 true;
    nix-index.enable = lib.mkOverride 100 true;
    ntfs.enable = lib.mkOverride 100 true;
    podman.enable = lib.mkOverride 100 true;
    ssh-server.enable = lib.mkOverride 100 true;
    systemd-boot.enable = lib.mkOverride 100 true;
  };
}
