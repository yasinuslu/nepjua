# NixOS Full ZFS Installation Guide (Flake-Centric, ZFS Boot, systemd-boot) - Using `/dev/disk/by-label` for ESP

## Hardware Reference Configuration

- CPU: AMD Ryzen 9 7950X3D (16-Core/32-Thread)
- Primary NVMe: Samsung 990 PRO 2TB (nvme0n1)
- Secondary NVMe: Patriot Viper VP4300L 4TB (nvme1n1)
- RAM: 64GB (61GB available to system)
- GPUs:
  - NVIDIA RTX 4090 (for VM passthrough)
  - AMD Raphael iGPU (host system)

## Prerequisites

- NixOS installation media (USB drive or ISO image)
- High-performance NVMe drives
- At least 32GB RAM for optimal ZFS caching (consider at least 8GB RAM for basic
  ZFS functionality)
- Stable internet connection during installation (for package downloads)
- Backup of all important data on the target drives before proceeding
- **Your NixOS flake repository cloned to `/home/nixos/code/nepjua` on the NixOS
  installation media**

## 1. Storage Layout

```plaintext
nvme0n1 (Samsung 990 PRO 2TB):
├── EFI partition (1GB)
└── ZFS partition (1.9TB) ─┐
                           ├── ZFS RAID0 pool (5.34TB total) - **Performance-focused, NO redundancy**
nvme1n1 (Patriot 4TB):     │
└── ZFS partition (3.9TB) ─┘

**Dataset Layout under `tank` pool:**
- `tank/root/nixos`:  Root filesystem dataset (mounted at `/`)
- `tank/nix`: Nix structure dataset (mounted at `/nix`)
- `tank/nix/store`: Nix store packages dataset (mounted at `/nix/store`)
- `tank/boot`: Boot dataset (mounted at `/boot`)
- `tank/vm`: Virtual machine images dataset (mounted at `/tank/vm`)
- `tank/data`: General data dataset (mounted at `/tank/data`)

**Important Note:** This guide uses RAID0 for the ZFS pool to maximize performance by striping data across both NVMe drives. **RAID0 provides NO data redundancy.** If either NVMe drive fails, **all data in the pool will be lost.**

**For users prioritizing data safety, consider using RAID1 (mirror) instead,** especially if you are only using two drives. RAID1 will halve the usable space but provide redundancy against a single drive failure.
```

## 2. Disk Preparation

1. Identify your disks:

```bash
ls -la /dev/disk/by-id/
```

2. Create partitions:

```bash
# Replace X with your disk identifiers
DISK1=/dev/disk/by-id/nvme-Samsung_SSD_990_PRO_2TB_S6Z2NJ0W445911J
DISK2=/dev/disk/by-id/nvme-Viper_VP4300L_4TB_VP4300LFDBA234200458

**WARNING: Double-check that DISK1 and DISK2 variables correctly identify your intended NVMe drives. Incorrect disk selection in the following commands WILL lead to DATA LOSS.**

# Create partition table on primary disk (nvme0n1 - Samsung 990 PRO 2TB)
parted $DISK1 -- mklabel gpt
parted $DISK1 -- mkpart ESP fat32 1MiB 1GiB
parted $DISK1 -- set 1 esp on
parted $DISK1 -- mkpart primary 1GiB 100%   # ZFS partition (for RAID0 pool, rest of disk)

# Create partition table on secondary disk (nvme1n1 - Patriot Viper VP4300L 4TB)
parted $DISK2 -- mklabel gpt
parted $DISK2 -- mkpart primary 1MiB 100%     # Full disk for ZFS (for RAID0 pool)

# Format boot partition (EFI)
mkfs.fat -F 32 -n boot ${DISK1}-part1

# **Label the EFI System Partition (ESP)**
fatlabel ${DISK1}-part1 boot-efi # Label the ESP partition as "boot-efi"

**Alternative to `parted`:** Some users may prefer `gdisk` for GPT partitioning. The commands would be different; consult `gdisk` documentation if you prefer to use it.
```

## 3. ZFS Pool Creation

Create the ZFS pool with performance-optimized settings:

```bash
# Create RAID0 pool for maximum performance
zpool create -f -o ashift=12 \
    -O mountpoint=none \
    -O acltype=posixacl \
    -O compression=lz4 \         # Fastest compression (lz4 is highly recommended for performance)
    -O atime=off \              # Disable access time updates (improves performance)
    -O xattr=sa \               # System attributes in inodes (performance improvement)
    -O dnodesize=auto \         # Let ZFS decide dnode size (generally optimal)
    -O normalization=formD \     # Unicode normalization (generally recommended default)
    tank ${DISK1}-part2 ${DISK2}-part1

# Create system datasets

zfs create -o mountpoint=none tank/root
zfs create -o mountpoint=/ \
    -o recordsize=32k \          # Optimal for mixed workloads (system files, config, etc.)
    -o compression=lz4 \
    -o atime=off \
    tank/root/nixos

# Create Nix structure datasets
zfs create -o mountpoint=/nix \
    -o recordsize=64k \          # Good compromise for Nix store (packages, derivations)
    -o compression=lz4 \
    -o atime=off \
    tank/nix
zfs create -o mountpoint=/nix/store \
    -o recordsize=64k \          # Good compromise for Nix store (packages, derivations)
    -o compression=lz4 \
    -o atime=off \
    tank/nix/store

# Create boot dataset
zfs create -o mountpoint=/boot \
    tank/boot

# Create VM dataset with optimal performance settings
zfs create -o mountpoint=/tank/vm \
    -o recordsize=64k \          # Optimal for VM images and general VM workload
    -o sync=disabled \           # **EXTREME PERFORMANCE, EXTREME DATA LOSS RISK!** - ONLY for non-critical VMs
    -o compression=lz4 \         # Fastest compression
    -o atime=off \
    -o logbias=throughput \      # Optimize for throughput (VM disk access)
    -o primarycache=all \        # Utilize ARC (RAM cache) for all data
    -o secondarycache=all \      # Utilize L2ARC (if configured, not in this guide) for all data
    tank/vm
**WARNING:** `sync=disabled` for `tank/vm` dataset significantly increases write performance for VMs, but it **completely disables synchronous writes and poses a SEVERE DATA LOSS RISK** in case of power failure or system crash. **Use `sync=disabled` ONLY for VMs where data loss is acceptable and you understand the risks.** For most VM use cases, use the default `sync=standard` or `sync=always` for data safety.


# Create data dataset
zfs create -o mountpoint=/tank/data \
    -o recordsize=1M \           # Larger blocks for general data storage (large files, media)
    -o compression=lz4 \
    -o atime=off \
    tank/data

**Recordsize Rationale:**
- `32k` for `tank/root/nixos`: Good for general system files and mixed workloads.
- `64k` for `tank/nix` and `tank/nix/store`: Compromise between metadata and data for package store and VM images.
- `1M` for `tank/data`: Optimal for large files and sequential I/O typical of general data storage.

**ARC and L2ARC:**
- `primarycache=all` and `secondarycache=all` settings utilize the ZFS Adaptive Replacement Cache (ARC) in RAM and, if configured, a Level 2 ARC (L2ARC) on SSD for caching data, improving read performance. With 64GB RAM, a 32GB ARC limit (set in kernel parameters later) is reasonable.
```

## 4. System Configuration (Flake-First, systemd-boot, ZFS /boot) - Manual `hardware-configuration.nix` (using `/dev/disk/by-label`)

This guide now exclusively uses NixOS flakes for system configuration and boots
from ZFS `/boot` using `systemd-boot`. We will create a `flake.nix` at the root
of your configuration repository which acts as the main entry point.
`configuration.nix` will be used as a module imported by the flake. We will also
manually configure `hardware-configuration.nix` to label the EFI System
Partition (ESP) using `/dev/disk/by-label` paths.

**Important:** Before proceeding, ensure you have cloned your NixOS flake
repository to `/home/nixos/code/nepjua` within the live NixOS environment.

1. Mount boot partition:

```bash
mount -t vfat ${DISK1}-part1 /mnt/boot
```

2. **Manually create and edit `hardware-configuration.nix`:**

Instead of auto-generating `hardware-configuration.nix`, we will create it
manually and use `/dev/disk/by-label` paths to specify the EFI System Partition
(ESP).

a. **Create `hardware-configuration.nix` at
`/home/nixos/code/nepjua/hardware-configuration.nix`:**

Create a new file named `hardware-configuration.nix` in your flake repository
directory (`/home/nixos/code/nepjua`).

b. **Verify the label for your EFI System Partition (ESP):**

Use the `ls -la /dev/disk/by-label/` command to list disk labels. After labeling
the ESP in the "Disk Preparation" step, you should see a label named `boot-efi`
(or whatever label you chose) pointing to your ESP partition.

The output will show symbolic links like this (example):

```plaintext
lrwxrwxrwx 1 root root 10 Feb 12 23:45 boot-efi ->../../nvme0n1p1
```

**Confirm that you see the `boot-efi` label (or your chosen label) and that it
points to the correct partition (e.g., `../../nvme0n1p1`).**

c. **Edit `/home/nixos/code/nepjua/hardware-configuration.nix`:**

Open `/home/nixos/code/nepjua/hardware-configuration.nix` in a text editor (like
`nano` or `vim`) and paste the following configuration.

```nix
# /home/nixos/code/nepjua/hardware-configuration.nix

{ config, lib, pkgs,... }:

{
  imports =
    [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix> ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" "vfat" "zfs" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ]; # or "kvm-amd"

  boot.zfs.forceImportRoot = false;
  boot.zfs.devNodes = "/dev/disk/by-id";

  fileSystems."/boot/efi" = {
    device = "/dev/disk/by-label/boot-efi"; # **Using /dev/disk/by-label/boot-efi for ESP**
    fsType = "vfat";
  };

  swapDevices = [ ];

  # Enables DHCPv4 client on enp7s0 - adjust interface name if needed
  networking.interfaces.enp7s0.useDHCP = true;
  networking.wireless.enable = false;  # Disable wireless

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "performance";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.video.hidpi.enable = lib.mkDefault false; # Disable HiDPI for now
}
```

**3. Create `flake.nix` at `/home/nixos/code/nepjua/flake.nix`:**

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable"; # Or your preferred nixpkgs version
    flake-utils.url = "github:numtide/flake-utils"; # Utility functions for flakes
    # Add other flake inputs here if needed (e.g., home-manager)
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        nixosConfigurations.kaori = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./configuration.nix # Import our main NixOS configuration as a module
            ./hardware-configuration.nix # Manually configured hardware config
            # Add other NixOS modules here, or from flake inputs
          ];
          # Special system configurations (systemd-boot, ZFS) are in configuration.nix
        };
      }
    );
}
```

**4. Edit `configuration.nix` at `/home/nixos/code/nepjua/configuration.nix`:**

```nix
{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ]; # Keep this import - hardware config is still needed

  nix = {
    settings.experimental-features = [ "nix-command" "flakes" ]; # Enable flakes - already in flake.nix, but good to have here too
    gc.automatic = true; # Enable garbage collection
  };

  networking.hostName = "kaori"; # Set hostname
  # networking.hostId = "$(head -c 8 /etc/machine-id)"; # Remove - usually unnecessary

  # ZFS support - crucial for ZFS root
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.devNodes = "/dev/disk/by-id";
  boot.zfs.enable = true; # Enable ZFS boot - necessary for ZFS root

  # Boot loader - systemd-boot for UEFI and ZFS /boot
  boot.loader.systemd-boot.enable = true; # Enable systemd-boot
  boot.loader.efi.canTouchEfiVariables = true; # Required for UEFI systemd-boot
  boot.loader.efi.efiSysMountPoint = "/boot/efi"; # **Explicitly set ESP mount point** - important for manual config

  # ZFS performance settings (kernel parameters)
  boot.kernelParams = [
    "zfs.zfs_arc_max=34359738368"      # 32GB max ARC size (adjust based on RAM)
    "zfs.zfs_txg_timeout=5"            # Faster transaction commits
    "zfs.zfs_vdev_async_read_max_active=12"
    "zfs.zfs_vdev_async_write_max_active=12"
  ];

  # ZFS service configuration
  services.zfs = {
    trim.enable = true;                 # Enable TRIM for SSDs
    autoScrub = {
      enable = true;
      interval = "weekly";             # Consider weekly for RAID0
    };
    # autoSnapshot.enable = false;        # Disabled for performance - consider enabling and tuning snapshots
    autoSnapshot.hourly.enable = true;   # Example: Enable hourly snapshots (tune retention in flake)
  };

  # VM related settings (libvirt, qemu)
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
          namespaces = [ ]
          user = "root"
          group = "root"
          clear_emulator_capabilities = 0
        '';
      };
    };
    spiceUSBRedirection.enable = true;
  };

  # Add user to libvirt and kvm groups (replace 'your-username')
  users.users.your-username.extraGroups = [ "libvirtd" "kvm" ];

  # System packages
  environment.systemPackages = with pkgs; [
    virt-manager
    virt-viewer
    spice-gtk
    win-virtio    # Windows VirtIO drivers
    swtpm         # TPM emulator
    arc-summary   # For ARC monitoring
    zfstools      # For zfs commands in recovery
  ];

  system.stateVersion = "24.05"; # Or your desired NixOS version
}
```

## 5. Installation and First Boot

1. Install NixOS using your flake configuration:

```bash
nixos-install --root /mnt --flake '/home/nixos/code/nepjua#kaori' # **Adjust the flake path and system name (`kaori`) if necessary to match your flake repository and system configuration name.**
# IMPORTANT: The path now points to the directory containing your flake in /home/nixos/code/nepjua, and the system name 'kaori' is defined in flake.nix
```

2. **Set root password:** You will be prompted to set the root password during
   the installation process. **Do not forget the root password\!**

3. Reboot:

```bash
reboot
```

## 6. Performance Monitoring

After installation and during system usage, you can use these commands to
monitor ZFS performance:

```bash
# Check compression ratio for a dataset (e.g., tank/vm)
zfs get compressratio tank/vm
# Output will show the compression ratio achieved (e.g., 2.50x means 2.5 times space saving)

# Monitor real-time I/O performance of the entire pool and individual vdevs (disks)
zpool iostat -v 1
# This command updates every 1 second. Look for:
# - Bandwidth (read/write MB/s)
# - Operations per second (ops)
# - Latency (latency, wait times)
# High latency or saturation can indicate performance bottlenecks.

# Check Adaptive Replacement Cache (ARC) statistics
arc_summary
# Provides detailed stats about ARC hit ratios, cache size, and memory usage.
# High hit ratios (e.g., >90% for primary cache) indicate efficient caching.

# Check ZFS dataset space usage, compression, and compression ratio
zfs list -o name,used,avail,compression,compressratio
# Shows used and available space, compression algorithm, and achieved compression ratio for each dataset.
```

## 7. Recovery Procedures

If your system fails to boot or you need to perform maintenance, boot from the
NixOS installation media.

1. **Check ZFS pool status:** Before importing, check the pool health:

```bash
zpool status tank
# Examine the output for any errors or pool degradation.
```

2. Import the ZFS pool:

```bash
zpool import -f tank
# `-f` (force) may be needed if the pool was not cleanly exported. Use with caution.
```

3. Mount essential filesystems:

```bash
mount -t zfs tank/root/nixos /mnt
mount -t zfs tank/boot /mnt/boot # Mount ZFS /boot dataset
mount -t vfat /dev/disk/by-label/boot-efi /mnt/boot/efi # Mount EFI partition under /boot/efi using label
```

4. Enter the installed NixOS system environment (chroot):

```bash
nixos-enter --root /mnt
# This command changes your root directory to /mnt, allowing you to run commands as if you were in your installed NixOS system.
# From here, you can try to diagnose and fix configuration issues, rebuild the system, etc.
```

**Recovery with ZFS Snapshots (if enabled):** If you have enabled ZFS snapshots,
you can potentially roll back to a previous snapshot of your `tank/root/nixos`
dataset to recover from configuration issues. This guide does not detail
snapshot rollback, but refer to ZFS documentation for snapshot management
commands (`zfs list -t snapshot`, `zfs rollback`).

## 8. VM Configuration for virt-manager

This section provides guidance on configuring virtual machines within
virt-manager to leverage the ZFS storage and optimize performance.

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
   - Use **virtio drivers** for all virtual devices (disk, network, graphics,
     etc.) for optimal performance. VirtIO is paravirtualized and designed for
     VMs.
   - **Enable CPU host-passthrough:** Allows the VM to directly utilize the host
     CPU's features and extensions, improving performance.
   - **Use hugepages for memory:** Hugepages can significantly improve VM memory
     performance by reducing TLB (Translation Lookaside Buffer) pressure.
   - **Configure NUMA for optimal CPU/memory access:**

**NUMA (Non-Uniform Memory Access) Explanation:** Modern CPUs, especially
multi-socket or high-core-count CPUs like the Ryzen 7950X3D, often use NUMA
architecture. NUMA means that memory access times are not uniform; accessing
memory closer to a CPU core is faster than accessing memory further away (e.g.,
memory attached to a different CPU socket or NUMA node).

**For optimal VM performance, it's crucial to align VM vCPUs and memory
allocation within the same NUMA node as much as possible.**

To determine your host's NUMA configuration, use commands like `lscpu --topo` or
`numactl --hardware` on your NixOS host. Then, configure your VM XML to match
the host NUMA layout.

Example VM XML snippets for best performance:

```xml
<cpu mode='host-passthrough' check='none' migratable='off'>
  <topology sockets='1' dies='1' cores='8' threads='2'/> <cache mode='passthrough'/>
  <feature policy='require' name='topoext'/>
</cpu>

<memory unit='GiB'>32</memory> <memoryBacking>
  <hugepages/>
  <allocation mode='immediate'/>
</memoryBacking>

<disk type='block' device='disk'>
  <driver name='qemu' type='raw' cache='none' io='native' discard='unmap'/>
  <source dev='/dev/zvol/tank/vm/windows'/> <target dev='vda' bus='virtio'/>
</disk>

<interface type='bridge'>
  <source bridge='br0'/> <model type='virtio'/>
  <driver name='vhost' queues='8'/>
</interface>
```

3. Performance monitoring for VMs:

```bash
# Monitor VM I/O performance (disk and network)
iostat -xm 1
# Look for disk and network I/O statistics for your VMs (device names will vary)

# Check VM CPU usage
virt-top
# Shows real-time CPU usage per VM and for the hypervisor

# Monitor ZFS VM dataset performance
zpool iostat -v tank/vm 1
# Specifically monitor the I/O performance of the `tank/vm` dataset
```

## 9. References

- [NixOS Manual](https://www.google.com/url?sa=E&source=gmail&q=https://nixos.org/manual/nixos/stable/)
- [OpenZFS Documentation](https://www.google.com/url?sa=E&source=gmail&q=https://openzfs.github.io/openzfs-docs/)
- [NixOS ZFS Wiki](https://www.google.com/url?sa=E&source=gmail&q=https://nixos.wiki/wiki/ZFS)

**Important Considerations when using `/dev/disk/by-label` paths:**

- **Labeling is crucial:** Ensure you correctly label the ESP partition in the
  "Disk Preparation" step using `fatlabel`. The label in
  `hardware-configuration.nix` **must exactly match** the label you set on the
  partition.
- **Potential for Label Conflicts:** If you have multiple partitions with the
  same label (e.g., if you reuse labels across different drives or systems),
  `/dev/disk/by-label` might become ambiguous, and NixOS might mount the wrong
  partition. **Ensure labels are unique within your system.**
- **Label Changes:** If you accidentally change or remove the label from the ESP
  partition after installation, your system **might fail to boot.**
- **Less Robust than UUIDs:** While labels are more human-readable than UUIDs,
  they are generally considered **less robust** for system configuration
  compared to UUIDs (`PARTUUID`) because labels can be more easily changed or
  accidentally duplicated.
- **If you encounter boot issues:** If you face boot problems after using
  `/dev/disk/by-label` paths, double-check that the label in
  `hardware-configuration.nix` exactly matches the label on your ESP partition.
  If issues persist, consider switching to `PARTUUID` in
  `hardware-configuration.nix` or even `/dev/disk/by-id` for potentially
  increased reliability.
