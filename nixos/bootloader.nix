{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  boot.loader = {
    grub = {
      enable = true;
      device = "nodev";
      useOSProber = true;
      efiSupport = true;
      default = "saved";
    };

    efi.canTouchEfiVariables = true;
  };

  boot.supportedFilesystems = ["btrfs" "ext4" "fat" "ntfs"];

  # Need this to have sync time on Windows.
  time.hardwareClockInLocalTime = true;
}
