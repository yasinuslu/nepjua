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

  hardware.opengl = let
    fn = oa: {
      nativeBuildInputs = oa.nativeBuildInputs ++ [pkgs.glslang];
      mesonFlags = oa.mesonFlags ++ ["-Dvulkan-layers=device-select,overlay"];
      #       patches = oa.patches ++ [ ./mesa-vulkan-layer-nvidia.patch ]; See below
      postInstall =
        oa.postInstall
        + ''
          mv $out/lib/libVkLayer* $drivers/lib

          #Device Select layer
          layer=VkLayer_MESA_device_select
          substituteInPlace $drivers/share/vulkan/implicit_layer.d/''${layer}.json \
            --replace "lib''${layer}" "$drivers/lib/lib''${layer}"

          #Overlay layer
          layer=VkLayer_MESA_overlay
          substituteInPlace $drivers/share/vulkan/explicit_layer.d/''${layer}.json \
            --replace "lib''${layer}" "$drivers/lib/lib''${layer}"
        '';
    };
  in
    with pkgs; {
      enable = true;
      driSupport32Bit = true;
      extraPackages = [mesa.drivers];
      extraPackages32 = [pkgsi686Linux.mesa.drivers];
      # package = (mesa.overrideAttrs fn).drivers;
      # package32 = (pkgsi686Linux.mesa.overrideAttrs fn).drivers;
    };

  hardware.nvidia.modesetting.enable = true;
}
