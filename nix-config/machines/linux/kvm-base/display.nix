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
  services.xserver.displayManager.gdm.wayland = true;
  services.xserver.desktopManager.gnome.enable = true;
  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;

  hardware.opengl.enable = true;
  hardware.opengl.driSupport = true;
  hardware.opengl.driSupport32Bit = true;
  hardware.opengl.extraPackages = with pkgs; [
    libva
    libdrm
    mesa
    vaapiVdpau
    libvdpau-va-gl
  ];
  hardware.opengl.extraPackages32 = with pkgs.pkgsi686Linux; [
    libva
    libdrm
    mesa
    vaapiVdpau
    libvdpau-va-gl
  ];

  # hardware.nvidia.datacenter.enable = true;
  # hardware.nvidia.prime.sync.enable = true;
  hardware.nvidia.modesetting.enable = true;
}
