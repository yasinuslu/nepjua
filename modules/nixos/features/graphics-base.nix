{
  pkgs,
  ...
}:
{
  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.xkb.layout = "us";
  services.xserver.xkb.variant = "";

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;

  environment.systemPackages = with pkgs; [
    mesa-demos
    # nixgl.auto.nixGLDefault
  ];
}
