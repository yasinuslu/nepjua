{
  inputs,
  myArgs,
  pkgs,
  ...
}:
{
  imports = [
    inputs.proxmox-nixos.nixosModules.proxmox-ve
    (
      { ... }:
      {
        nixpkgs.overlays = [
          inputs.proxmox-nixos.overlays.${myArgs.system}
        ];

        services.proxmox-ve = {
          enable = true;
          ipAddress = "192.168.50.50";
        };
      }
    )
  ];

  systemd.network.networks."10-lan" = {
    matchConfig.Name = [ "eno1" ];
    networkConfig = {
      Bridge = "vmbr0";
    };
  };

  systemd.network.netdevs."vmbr0" = {
    netdevConfig = {
      Name = "vmbr0";
      Kind = "bridge";
      MACAddress = "08:bf:b8:6c:67:2e";
    };
  };

  systemd.network.networks."10-lan-bridge" = {
    matchConfig.Name = "vmbr0";
    networkConfig = {
      IPv6AcceptRA = true;
      DHCP = "ipv4";
    };
    linkConfig.RequiredForOnline = "routable";
  };

  # Required packages
  environment.systemPackages = with pkgs; [
    virt-viewer
    spice-gtk
    win-virtio # Windows VirtIO drivers
    win-spice # Windows SPICE drivers
    swtpm # Software TPM emulator
    looking-glass-client
    guestfs-tools
  ];

  # Kernel configuration for virtualization
  boot = {
    kernelParams = [
      "amd_iommu=on"
      "iommu=pt"
      "kvm.ignore_msrs=1"
      "kvm.report_ignored_msrs=0"
    ];
    kernelModules = [
      "kvm-amd"
      "vfio"
      "vfio_iommu_type1"
      "vfio_pci"
      "vfio_virqfd"
      "kvmfr"
    ];
    blacklistedKernelModules = [
      "nouveau"
      "nvidia"
      "nvidia_drm"
      "nvidia_uvm"
      "nvidia_modeset"
    ];
  };
}
