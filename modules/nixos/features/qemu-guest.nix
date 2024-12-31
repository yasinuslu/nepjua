{pkgs, ...}: {
  # QEMU/SPICE guest services
  services = {
    qemuGuest.enable = true;

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

  # Hardware support
  hardware.nvidia = {
    modesetting.enable = false;
    powerManagement.enable = false;
    open = false;
  };

  # SPICE agent for better integration
  virtualisation = {
    spiceAgent.enable = true;
    vmware.guest.enable = false;
    virtualbox.guest.enable = false;
  };
}
