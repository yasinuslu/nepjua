{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  # boot.initrd.availableKernelModules = [
  #   "ata_piix"
  #   "uhci_hcd"
  #   "virtio_pci"
  #   "virtio_scsi"
  #   "virtio_net"
  #   "virtio_balloon"
  #   "xhci_pci"
  #   "virtio_rng"
  #   "virtio_mmio"
  #   "virtio_blk"
  #   "sd_mod"
  #   "sr_mod"
  # ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  # swapDevices = [
  #   { device = "/dev/disk/by-label/swap"; }
  # ];

  fileSystems."/boot/efi" = {
    device = "/dev/disk/by-label/EFI";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
