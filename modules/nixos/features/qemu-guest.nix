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
    # QEMU/SPICE guest services
    qemuGuest.enable = true;
    spice-vdagent.enable = true;
    spice-autorandr.enable = true;
    spice-webdavd.enable = true;

    # X11 configuration
    xserver = {
      enable = true;
      videoDrivers = ["virtio"];

      # Input configuration
      libinput = {
        enable = true;
      };

      xkb = {
        layout = "us";
        variant = "";
      };
    };
  };

  environment.systemPackages = with pkgs; [
    mesa-demos # Useful for testing GL support
  ];
}
