{
  inputs,
  myArgs,
  pkgs,
  lib,
  config,
  ...
}:
let
  overridden-proxmox-ve = inputs.proxmox-nixos.packages.${myArgs.system}.proxmox-ve.overrideAttrs (
    finalAttrs: previousAttrs: {
      buildInputs = previousAttrs.buildInputs ++ [ pkgs.swtpm ];
      nativeBuildInputs = previousAttrs.nativeBuildInputs ++ [ pkgs.swtpm ];
    }
  );
in
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
          package = overridden-proxmox-ve;
        };
      }
    )
  ];

  config = {
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
      # Required packages
      looking-glass-client

      # TODO: Put the correct places in the proxmox-ve module
      swtpm # Software TPM emulator
      openssl
      perlPackages.XMLLibXML

      # Optional packages
      virt-viewer
      spice-gtk
      win-virtio # Windows VirtIO drivers
      win-spice # Windows SPICE drivers
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
    };
  };
}
