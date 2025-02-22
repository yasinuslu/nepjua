{
  config,
  pkgs,
  lib,
  ...
}:
{
  options.myNixOS.xserver = {
    nvidia.enable = lib.mkEnableOption "NVIDIA GPU";
  };

  config = lib.mkMerge [
    {
      environment.systemPackages = with pkgs; [
        mesa-demos
        # nixgl.auto.nixGLDefault
      ];

      services.xserver.xkb.layout = "us";
      services.xserver.xkb.variant = "";

      # Enable the X11 windowing system.
      services.xserver.enable = true;
      services.xserver.videoDrivers = [
        "amdgpu"
      ];

      # Enable touchpad support (enabled default in most desktopManager).
      services.libinput.enable = true;

      hardware.graphics.enable = true;
      hardware.graphics.enable32Bit = true;

      hardware.amdgpu.amdvlk.enable = true;
      hardware.amdgpu.amdvlk.support32Bit.enable = true;
    }
    (lib.mkIf config.myNixOS.xserver.nvidia.enable {
      hardware.nvidia-container-toolkit.enable = true;
      hardware.nvidia.modesetting.enable = true;
      hardware.nvidia.powerManagement.enable = true;
      hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;
      hardware.nvidia.open = true;
      services.xserver.videoDrivers = [
        "amdgpu"
        "nvidia"
      ];
    })
    (lib.mkIf (!config.myNixOS.xserver.nvidia.enable) {
      boot.blacklistedKernelModules = [
        "nouveau"
        "nvidia"
        "nvidia_drm"
        "nvidia_uvm"
        "nvidia_modeset"
      ];
    })
  ];
}
