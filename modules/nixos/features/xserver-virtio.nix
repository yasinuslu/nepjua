{
  config,
  pkgs,
  ...
}: {
  # nixpkgs.overlays = [inputs.nixgl.overlay];

  environment.systemPackages = with pkgs; [
    mesa-demos
    # nixgl.auto.nixGLDefault
  ];

  hardware.bumblebee.connectDisplay = true;

  services.xserver.xkb.layout = "us";
  services.xserver.xkb.variant = "";

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.videoDrivers = ["virtio"];

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;

  # Adjustments for QEMU guest
  hardware.nvidia.modesetting.enable = false;
  hardware.nvidia.powerManagement.enable = false;
  hardware.nvidia.open = false;

  # Add QEMU specific configurations
  services.qemuGuest.enable = true;
  hardware.qemuGuest.enable = true;
}
