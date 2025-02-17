# Proper VFIO Windows Installation Guide

## Hardware Reference Configuration

- CPU: AMD Ryzen 9 7950X3D (16-Core/32-Thread)
- Primary NVMe: Samsung 990 PRO 2TB (nvme0n1) - OS, /boot, /nix, /home, ZIL
- Secondary NVMe: Patriot Viper VP4300L 4TB (nvme1n1) - /tank/vm, /tank/data,
  L2ARC
- RAM: 64GB (61GB available to system)
- GPUs:
  - NVIDIA RTX 4090 (for VM passthrough)
  - AMD Raphael iGPU (host system)

## Prerequisites

- Install NixOS using the [ZFS installation guide](./zfs-installation.md)

## Planning

Here are some key considerations and potential pitfalls to be aware of as you
plan your VFIO setup:

- **IOMMU Group Isolation**: Ensure that the NVIDIA RTX 4090 you intend to pass
  through is in its own IOMMU group. Poor IOMMU grouping can lead to issues or
  prevent VFIO from working correctly. You'll need to check your IOMMU groups to
  confirm isolation.
- **Driver Blacklisting**: You must prevent the host system from loading drivers
  for the NVIDIA RTX 4090. This is crucial to allow VFIO to take control of the
  GPU. Incorrect blacklisting can lead to conflicts and prevent the VM from
  accessing the GPU.
- **VFIO Kernel Modules**: Verify that the necessary VFIO kernel modules
  (`vfio`, `vfio_iommu_type1`, `vfio_pci`) are loaded by your NixOS
  configuration. Without these modules, VFIO passthrough is impossible.
- **Libvirt Configuration**: Carefully configure libvirt to utilize VFIO and
  correctly pass the NVIDIA RTX 4090 to the Windows VM. Incorrect libvirt
  configuration is a common source of problems.
- **Windows VM Drivers**: Be prepared to install the correct NVIDIA drivers
  within the Windows VM, as well as any necessary paravirtualized drivers (like
  VirtIO drivers for storage and networking) for optimal performance.
- **BIOS/UEFI Settings**: Certain BIOS/UEFI settings, such as enabling IOMMU and
  virtualization (VT-d/AMD-Vi), are prerequisites. Also, settings like "Above 4G
  Decoding" or "Resizable BAR Support" might be necessary or beneficial for
  modern GPUs.
- **Power Supply**: Ensure your power supply is adequate for running both the
  host system and the power-hungry RTX 4090 under load in the VM. VFIO setups
  can increase power demand.
- **Cooling**: Similar to power, ensure your system has adequate cooling for
  both the CPU and GPU, especially when the VM is running and the RTX 4090 is
  under load.

Addressing these points proactively will help ensure a smoother and more
successful VFIO Windows installation.
