{
  inputs,
  lib,
  config,
  pkgs,
  colors,
  ...
}: {
  services.xserver.xkb.layout = "us";
  services.xserver.xkb.variant = "";

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.videoDrivers = ["qxl" "radeon" "nvidia"];
  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.gdm.wayland = true;
  services.xserver.desktopManager.gnome.enable = true;
  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;

  services.xserver.xrandrHeads = [
    "DP-2"
    "DP-4"
  ];
}
