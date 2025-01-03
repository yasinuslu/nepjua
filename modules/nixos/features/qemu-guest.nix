{pkgs, ...}: {
  # First, specifically disable VMware and VirtualBox guests
  virtualisation = {
    vmware.guest.enable = false;
    virtualbox.guest.enable = false;
  };

  # Specifically disable NVIDIA features
  hardware.nvidia = {
    modesetting.enable = false;
    powerManagement.enable = false;
    open = false;
  };

  services = {
    # Enable QEMU guest agent
    qemuGuest.enable = true;

    # X11 configuration
    xserver = {
      videoDrivers = ["virtio"];
    };
  };

  # System-wide QEMU guest optimizations
  boot.kernelModules = ["virtio" "virtio_net" "virtio_pci" "virtio_balloon"];

  environment.systemPackages = with pkgs; [
    mesa-demos # Useful for testing GL support
  ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;
}
