{ lib, ... }:
{
  boot.supportedFilesystems = [ "zfs" ];
  boot.initrd.supportedFilesystems = {
    zfs = lib.mkForce true;
  };
  boot.zfs = {
    # enabled = lib.mkForce true;
    forceImportRoot = lib.mkForce false;
    # extraPools = [ "zpool" ];
  };

  services.zfs = {
    # autoReplication = {
    #   enable = true;
    #   username = "nepjua";
    # };
    autoScrub.enable = true;
    autoSnapshot.enable = true;
    trim.enable = true;
  };
}
