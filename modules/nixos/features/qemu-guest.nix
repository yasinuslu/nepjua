{pkgs, ...}: {
  # QEMU/SPICE guest services
  services = {
    qemuGuest.enable = true;
    spice-vdagent.enable = true;

    # X11 configuration
    xserver = {
      enable = true;
      videoDrivers = ["virtio"];

      # Input configuration
      libinput = {
        enable = true;
        # You might want to add specific touchpad/mouse settings here
        # touchpad.tapping = true;
        # mouse.accelProfile = "flat";
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
    vmware.guest.enable = false; # Explicitly disable VMware guest
    virtualbox.guest.enable = false; # Explicitly disable VBox guest
  };
}
