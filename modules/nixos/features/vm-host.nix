{ pkgs, ... }:
{
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      ovmf = {
        enable = true;
        packages = [ pkgs.OVMFFull.fd ];
      };
      runAsRoot = true;
      swtpm = {
        enable = true;
      };
    };
  };

  virtualisation.spiceUSBRedirection.enable = true;

  services.spice-vdagentd.enable = true;

  programs.virt-manager.enable = true;

  # Add additional useful packages
  environment.systemPackages = with pkgs; [
    virt-viewer
    spice-gtk
    win-virtio
    win-spice
  ];

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
