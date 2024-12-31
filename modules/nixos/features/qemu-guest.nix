{pkgs, ...}: {
  # QEMU/SPICE guest services
  services = {
    qemuGuest.enable = true;
    spice-vdagent.enable = true;

    # X11 configuration
    xserver = {
      enable = true;
      videoDrivers = ["virtio"];

      xkb = {
        layout = "us";
        variant = "";
      };
    };

    # Input device support
    libinput.enable = true;
  };

  environment.systemPackages = with pkgs; [
    mesa-demos # Useful for testing GL support
  ];

  # Hardware support
  hardware = {
    qemuGuest.enable = true;

    # Explicitly disable NVIDIA features
    nvidia = {
      modesetting.enable = false;
      powerManagement.enable = false;
      open = false;
    };
  };

  # Enable SPICE agent for better integration
  virtualisation.spiceAgent.enable = true;
}
