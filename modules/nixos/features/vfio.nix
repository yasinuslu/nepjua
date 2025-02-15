{ ... }:
{
  boot = {
    kernelParams = [
      "amd_iommu=on"
      "iommu=pt"
    ];
    initrd.kernelModules = [
      "vfio_pci"
      "vfio_iommu_type1"
      "vfio_virqfd"
    ];
    blacklistedKernelModules = [
      "nouveau"
      "nvidiafb"
      "nvidia-gpu"
    ];
    extraModprobeConfig = ''
      options vfio-pci ids=0000:01:00.0,0000:01:00.1 # Replace with your GPU PCI IDs
    '';
  };
}
