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
        wl-clipboard
        xclip
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

      services.printing.enable = true;

      # Enable sound with pipewire.
      services.pulseaudio.enable = false;
      security.rtkit.enable = true;
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
      };

      # Enable automatic login for the user.
      services.getty.autologinUser = config.myNixOS.mainUser;
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
