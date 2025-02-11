{ lib, ... }:
{
  boot.supportedFilesystems = [ "zfs" ];
  boot.initrd.supportedFilesystems = {
    zfs = lib.mkDefault true;
  };
  boot.zfs = {
    enabled = lib.mkDefault true;
    forceImportRoot = lib.mkDefault false;
    extraPools = [ "zpool" ];
  };

  services.zfs = {
    autoReplication.enable = true;
    autoScrub.enable = true;
    autoSnapshot.enable = true;
    trim.enable = true;
  };
}
