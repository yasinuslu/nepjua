# NixOS Full ZFS Installation Guide

## Hardware Reference Configuration

- CPU: AMD Ryzen 9 7950X3D (16-Core/32-Thread)
- Primary NVMe: Samsung 990 PRO 2TB (nvme0n1)
- Secondary NVMe: Patriot Viper VP4300L 4TB (nvme1n1)
- RAM: 64GB (61GB available to system)
- GPUs:
  - NVIDIA RTX 4090 (for VM passthrough)
  - AMD Raphael iGPU (host system)

## Prerequisites

- NixOS installation media
- High-performance NVMe drives
- At least 32GB RAM for optimal ZFS caching

## 1. Storage Layout

```plaintext
nvme0n1 (Samsung 990 PRO 2TB):
├── EFI partition (1GB)
├── System partition (99GB)
└── Data partition (1.7TB) ─┐
                           ├── ZFS RAID0 pool (5.34TB total)
nvme1n1 (Patriot 4TB):     │
└── Data partition (3.6TB) ─┘
```

## 2. Disk Preparation

1. Identify your disks:

```bash
ls -la /dev/disk/by-id/
```

2. Create partitions:

```bash
# Replace X with your disk identifiers
DISK1=/dev/disk/by-id/nvme-Samsung_990_PRO_2TB
DISK2=/dev/disk/by-id/nvme-Patriot_Viper_VP4300L_4TB

# Create partition table on primary disk
parted $DISK1 -- mklabel gpt
parted $DISK1 -- mkpart ESP fat32 1MiB 1GiB
parted $DISK1 -- set 1 boot on
parted $DISK1 -- mkpart primary 1GiB 100GiB  # System partition
parted $DISK1 -- mkpart primary 100GiB 100%   # ZFS partition

# Create partition table on secondary disk
parted $DISK2 -- mklabel gpt
parted $DISK2 -- mkpart primary 1MiB 100%     # Full disk for ZFS

# Format boot partition
mkfs.fat -F 32 -n boot ${DISK1}-part1
```

## 3. ZFS Pool Creation

Create the ZFS pool with performance-optimized settings:

```bash
# Create RAID0 pool for maximum performance
zpool create -f -o ashift=12 \
    -O mountpoint=none \
    -O acltype=posixacl \
    -O compression=lz4 \         # Fastest compression
    -O atime=off \              # Disable access time updates
    -O xattr=sa \               # System attributes in inodes
    -O relatime=off \           # Disable relative access time
    -O dnodesize=auto \
    -O normalization=formD \
    tank ${DISK1}-part3 ${DISK2}-part1

# Create system datasets
zfs create -o mountpoint=none tank/root
zfs create -o mountpoint=/ \
    -o recordsize=32k \          # Better for mixed workloads
    -o compression=lz4 \
    -o atime=off \
    tank/root/nixos

# Create Nix store dataset
zfs create -o mountpoint=/nix \
    -o recordsize=64k \
    -o compression=lz4 \
    -o atime=off \
    tank/nix

# Create VM dataset with optimal performance settings
zfs create -o mountpoint=/tank/vm \
    -o recordsize=64k \          # Optimal for VM images
    -o sync=disabled \           # Maximum write performance
    -o compression=lz4 \         # Fastest compression
    -o atime=off \
    -o logbias=throughput \      # Optimize for throughput
    -o primarycache=all \        # Use ARC for all data
    -o secondarycache=all \
    tank/vm

# Create data dataset
zfs create -o mountpoint=/tank/data \
    -o recordsize=1M \           # Larger blocks for general data
    -o compression=lz4 \
    -o atime=off \
    tank/data
```

## 4. System Configuration

1. Mount boot partition:

```bash
mount -t vfat ${DISK1}-part1 /mnt/boot
```

2. Generate NixOS configuration:

```bash
nixos-generate-config --root /mnt
```

3. Edit configuration.nix:

```nix
{ config, ... }:
{
  imports = [ ./hardware-configuration.nix ];

  networking.hostId = "$(head -c 8 /etc/machine-id)";
  networking.hostName = "kaori";
  
  # ZFS support
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.devNodes = "/dev/disk/by-id";

  # Boot loader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # ZFS performance settings
  boot.kernelParams = [
    "zfs.zfs_arc_max=34359738368"      # 32GB max ARC size
    "zfs.zfs_txg_timeout=5"            # Faster transaction commits
    "zfs.zfs_vdev_async_read_max_active=12"
    "zfs.zfs_vdev_async_write_max_active=12"
  ];

  # ZFS service configuration
  services.zfs = {
    trim.enable = true;                 # Enable TRIM for SSDs
    autoScrub = {
      enable = true;
      interval = "monthly";             # Reduced scrub frequency
    };
    autoSnapshot.enable = false;        # Disable for better performance
  };

  # If using VMs, optimize virtio settings
  virtualisation.libvirtd.qemu.verbatimConfig = ''
    namespaces = []
    user = "root"
    group = "root"
    clear_emulator_capabilities = 0
  '';

  # VM support
  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        swtpm.enable = true;
        ovmf = {
          enable = true;
          packages = [(pkgs.OVMF.override {
            secureBoot = true;
            tpmSupport = true;
          })];
        };
        verbatimConfig = ''
          namespaces = []
          user = "root"
          group = "root"
          clear_emulator_capabilities = 0
        '';
      };
    };
    spiceUSBRedirection.enable = true;
  };

  # Add user to libvirt groups
  users.users.your-username.extraGroups = [ "libvirtd" "kvm" ];

  # Required packages
  environment.systemPackages = with pkgs; [
    virt-manager
    virt-viewer
    spice-gtk
    win-virtio    # Windows VirtIO drivers
    swtpm         # TPM emulator
  ];
}
```

## 5. Installation and First Boot

1. Install:

```bash
nixos-install
```

2. Set root password when prompted

3. Reboot:

```bash
reboot
```

## Performance Monitoring

```bash
# Check compression ratio
zfs get compressratio tank/vm

# Monitor IO performance
zpool iostat -v 1

# Check ARC stats
arc_summary

# Check space usage
zfs list -o name,used,avail,compression,compressratio
```

## Recovery Procedures

If needed, boot from installation media and:

```bash
# Import pool
zpool import -f tank

# Mount filesystems
mount -t zfs tank/root/nixos /mnt
mount -t vfat ${DISK1}-part1 /mnt/boot

# Enter system
nixos-enter --root /mnt
```

## References

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [OpenZFS Documentation](https://openzfs.github.io/openzfs-docs/)
- [NixOS ZFS Wiki](https://nixos.wiki/wiki/ZFS)

## VM Configuration for virt-manager

1. Optimal VM storage configuration in virt-manager:
   - Storage pool configuration:

```xml
<pool type='zfs'>
  <name>tank</name>
  <source>
    <name>tank/vm</name>
  </source>
  <target>
    <path>/tank/vm</path>
  </target>
</pool>
```

2. VM performance optimizations:
   - Use virtio drivers for all devices
   - Enable CPU host-passthrough
   - Use hugepages for memory
   - Configure NUMA for optimal CPU/memory access

Example VM XML snippets for best performance:

```xml
<!-- CPU configuration -->
<cpu mode='host-passthrough' check='none' migratable='off'>
  <topology sockets='1' dies='1' cores='8' threads='2'/>
  <cache mode='passthrough'/>
  <feature policy='require' name='topoext'/>
</cpu>

<!-- Memory configuration -->
<memory unit='GiB'>32</memory>
<memoryBacking>
  <hugepages/>
  <allocation mode='immediate'/>
</memoryBacking>

<!-- Disk configuration -->
<disk type='block' device='disk'>
  <driver name='qemu' type='raw' cache='none' io='native' discard='unmap'/>
  <source dev='/dev/zvol/tank/vm/windows'/>
  <target dev='vda' bus='virtio'/>
</disk>

<!-- Network configuration -->
<interface type='bridge'>
  <source bridge='br0'/>
  <model type='virtio'/>
  <driver name='vhost' queues='8'/>
</interface>
```

3. Performance monitoring for VMs:

```bash
# Monitor VM I/O performance
iostat -xm 1

# Check VM CPU usage
virt-top

# Monitor ZFS VM dataset
zpool iostat -v tank/vm 1
```

4. VM-specific ZFS tuning:

```bash
# Optimize ZFS dataset for specific VM
zfs set primarycache=metadata tank/vm/windows-boot
zfs set sync=disabled tank/vm/windows-games
```
