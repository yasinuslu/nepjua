{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "ahci"
    "usbhid"
    "usb_storage"
    "sd_mod"
    "zfs"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  boot.zfs.forceImportRoot = false;
  boot.zfs.devNodes = "/dev/disk/by-id";

  fileSystems."/" = {
    device = "tank/system/root";
    fsType = "zfs";
    options = [
      "zfsutil"
      "noatime"
      "xattr"
    ];
    neededForBoot = true;
  };

  fileSystems."/nix" = {
    device = "tank/system/nix";
    fsType = "zfs";
    options = [
      "zfsutil"
      "noatime"
      "xattr"
    ];
    neededForBoot = true;
  };

  fileSystems."/nix/store" = {
    device = "tank/system/nix/store";
    fsType = "zfs";
    options = [
      "zfsutil"
      "noatime"
      "xattr"
    ];
    neededForBoot = true;
  };

  fileSystems."/boot" = {
    device = "tank/system/boot";
    fsType = "zfs";
    options = [
      "zfsutil"
      "noatime"
      "xattr"
    ];
    neededForBoot = true;
  };

  fileSystems."/boot/efi" = {
    device = "/dev/disk/by-label/BOOT-EFI";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  fileSystems."/var" = {
    device = "tank/system/var";
    fsType = "zfs";
    options = [
      "zfsutil"
      "noatime"
      "xattr"
    ];
    neededForBoot = true;
  };

  fileSystems."/home" = {
    device = "tank/user/home";
    fsType = "zfs";
    options = [
      "zfsutil"
      "noatime"
      "xattr"
    ];
    neededForBoot = false;
  };

  fileSystems."/home/nepjua/.nix-mutable" = {
    device = "tank/user/nepjua-nix-mutable";
    fsType = "zfs";
    options = [
      "zfsutil"
      "noatime"
      "xattr"
    ];
    neededForBoot = false;
  };

  fileSystems."/persist" = {
    device = "tank/user/persist";
    fsType = "zfs";
    options = [
      "zfsutil"
      "noatime"
      "xattr"
    ];
    neededForBoot = false;
  };

  fileSystems."/tank/vm" = {
    device = "tank/data/vm";
    fsType = "zfs";
    options = [
      "zfsutil"
      "noatime"
      "xattr"
    ];
    neededForBoot = false;
  };

  fileSystems."/tank/data" = {
    device = "tank/data/storage";
    fsType = "zfs";
    options = [
      "zfsutil"
      "noatime"
      "xattr"
    ];
    neededForBoot = false;
  };

  fileSystems."/tmp" = {
    device = "tmpfs";
    fsType = "tmpfs";
    options = [
      "size=4G"
      "mode=1777"
    ];
  };

  swapDevices = [ ];

  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.eno1.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp9s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
