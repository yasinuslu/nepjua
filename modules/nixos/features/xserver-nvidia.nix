{
  config,
  inputs,
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
  services.xserver.videoDrivers = ["nvidia"];

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;

  hardware.nvidia.modesetting.enable = true;
  hardware.nvidia.powerManagement.enable = true;
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;
  # hardware.nvidia.forceFullCompositionPipeline = true;
  # hardware.nvidiaOptimus.disable = true;
  hardware.nvidia.open = true;
}
