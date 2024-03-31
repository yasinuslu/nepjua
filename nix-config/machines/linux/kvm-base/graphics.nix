{
  inputs,
  lib,
  config,
  pkgs,
  colors,
  ...
}: {
  # services.xrdp.enable = true;
  # services.xrdp.openFirewall = true;
  # services.xrdp.defaultWindowManager = "gnome-session";

  hardware.bumblebee.connectDisplay = true;

  services.xserver.xkb.layout = "us";
  services.xserver.xkb.variant = "";

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.videoDrivers = ["nvidia"];
  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.gdm.wayland = false;
  services.xserver.desktopManager.gnome.enable = true;
  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;

  environment.systemPackages = with pkgs; [
    libva
    libdrm
    libGL
    mesa
    mesa-demos
    vaapiVdpau
    libvdpau-va-gl
    virtualgl
    virtualglLib
  ];

  hardware.opengl.enable = true;
  hardware.opengl.driSupport = true;
  hardware.opengl.driSupport32Bit = true;

  hardware.nvidia.modesetting.enable = true;
  hardware.nvidia.powerManagement.enable = true;
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;
  # hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.vulkan_beta;
  hardware.nvidia.open = true;
}
