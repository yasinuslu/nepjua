{ lib, ... }:
{
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs = {
    forceImportRoot = true;
    devNodes = "/dev/disk/by-id";
    extraPools = [ "tank" ];
  };
  boot.initrd.supportedFilesystems = {
    zfs = lib.mkForce true;
  };

  # Add performance tuning parameters
  boot.kernelParams = [
    "zfs.zfs_arc_max=34359738368" # 32GB max ARC size (adjust based on your RAM)
    "zfs.zfs_txg_timeout=5" # Faster sync writes
    "zfs.zfs_vdev_async_read_max_active=12"
    "zfs.zfs_vdev_async_write_max_active=12"
  ];

  services.zfs = {
    trim.enable = true;
    autoScrub = {
      enable = true;
      interval = "weekly";
    };
    autoSnapshot.enable = true;
  };
}
