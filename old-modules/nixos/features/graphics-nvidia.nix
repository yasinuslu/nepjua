{
  config,
  ...
}:
{

  hardware.bumblebee.connectDisplay = true;
  hardware.nvidia-container-toolkit.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia.modesetting.enable = true;
  hardware.nvidia.powerManagement.enable = true;
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;
  # hardware.nvidia.forceFullCompositionPipeline = true;
  # hardware.nvidiaOptimus.disable = true;
  hardware.nvidia.open = true;
}
