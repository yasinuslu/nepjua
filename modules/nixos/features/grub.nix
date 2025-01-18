{lib, ...}: {
  # Disable systemd-boot
  boot.loader.systemd-boot.enable = lib.mkForce false;

  # Enable GRUB bootloader
  boot.loader.grub = {
    enable = true;
    # Default to BIOS, but allow for easy UEFI configuration
    efiSupport = lib.mkDefault false;

    # Automatically detect other operating systems
    useOSProber = lib.mkDefault true;

    # Install GRUB to the default location
    # This can be customized per-host if needed
    devices = ["nodev"];
  };

  # Optional: Enable EFI if needed
  boot.loader.efi = {
    canTouchEfiVariables = lib.mkDefault false;
  };
}
