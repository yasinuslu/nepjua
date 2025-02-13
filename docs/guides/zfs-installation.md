# NixOS Full ZFS Installation Guide (Flake-Centric, ZFS Boot, systemd-boot)

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
- At least 32GB RAM for optimal ZFS caching
- Stable internet connection
- Backup of all important data (drives will be completely wiped)
- Your NixOS flake repository cloned to `/home/nixos/code/nepjua`

## 1. Storage Layout

```plaintext
nvme0n1 (Samsung 990 PRO 2TB):
├── EFI partition (1GB)
└── ZFS partition (1.9TB) ─┐
                          ├── ZFS RAID0 pool (5.34TB total)
nvme1n1 (Patriot 4TB):    │
└── ZFS partition (3.9TB) ─┘

Dataset Layout:
tank/
├── root/
│   └── nixos  (/)
├── nix        (/nix)
│   └── store  (/nix/store)
├── boot       (/boot)
├── vm         (/tank/vm)
└── data       (/tank/data)

Note: RAID0 provides NO redundancy - data loss if either drive fails
```

## 2. Initial Setup

1. Boot from NixOS installation media and verify disks:

```bash
ls -la /dev/disk/by-id/ | grep -E 'nvme-Samsung|nvme-Viper'
```

2. Set disk variables (adjust paths based on your output):

```bash
DISK1=/dev/disk/by-id/nvme-Samsung_SSD_990_PRO_2TB_S6Z2NJ0W445911J
DISK2=/dev/disk/by-id/nvme-Viper_VP4300L_4TB_VP4300LFDBA234200458

# Verify variables are set correctly
echo "DISK1: $DISK1"
echo "DISK2: $DISK2"
```

3. Completely wipe both disks:

```bash
wipefs -a ${DISK1}
wipefs -a ${DISK2}
```

4. Create partitions:

```bash
# Primary disk
parted ${DISK1} -- mklabel gpt
parted ${DISK1} -- mkpart ESP fat32 1MiB 1GiB
parted ${DISK1} -- set 1 esp on
parted ${DISK1} -- mkpart primary 1GiB 100%

# Secondary disk
parted ${DISK2} -- mklabel gpt
parted ${DISK2} -- mkpart primary 1MiB 100%

# Format and label ESP
mkfs.fat -F 32 -n BOOT-EFI ${DISK1}-part1
```

## 3. ZFS Pool Creation

1. Create the pool with optimal settings:

```bash
zpool create -f -o ashift=12 \
    -O mountpoint=none \
    -O acltype=posixacl \
    -O compression=lz4 \
    -O atime=off \
    -O xattr=sa \
    -O dnodesize=auto \
    -O normalization=formD \
    tank ${DISK1}-part2 ${DISK2}-part1

# Verify pool creation
zpool status tank
```

2. Create root dataset structure with optimized properties:

```bash
# Root structure with 32k recordsize (optimized for OS and small files)
zfs create -u -o mountpoint=none \
    -o recordsize=32k \
    -o primarycache=all \
    -o logbias=latency \
    -o sync=disabled \
    -o acltype=posixacl \
    -o xattr=sa \
    -o atime=off \
    -o compression=lz4 \
    -o dnodesize=auto \
    -o normalization=formD \
    tank/root/nixos

# Nix structure with 64k recordsize (optimized for package management)
zfs create -u -o mountpoint=none \
    -o recordsize=64k \
    -o primarycache=all \
    -o logbias=latency \
    -o sync=disabled \
    -o acltype=posixacl \
    -o xattr=sa \
    -o atime=off \
    -o compression=lz4 \
    -o dnodesize=auto \
    -o normalization=formD \
    tank/nix

zfs create -u -o mountpoint=none \
    -o recordsize=64k \
    -o primarycache=all \
    -o logbias=latency \
    -o sync=disabled \
    -o acltype=posixacl \
    -o xattr=sa \
    -o atime=off \
    -o compression=lz4 \
    -o dnodesize=auto \
    -o normalization=formD \
    tank/nix/store

# Boot dataset (optimized for small files)
zfs create -u -o mountpoint=none \
    -o recordsize=32k \
    -o primarycache=all \
    -o logbias=latency \
    -o sync=disabled \
    -o acltype=posixacl \
    -o xattr=sa \
    -o atime=off \
    -o compression=lz4 \
    -o dnodesize=auto \
    -o normalization=formD \
    tank/boot

# VM dataset (optimized for VM images and performance)
zfs create -u -o mountpoint=none \
    -o recordsize=64k \
    -o primarycache=all \
    -o logbias=throughput \
    -o sync=disabled \
    -o acltype=posixacl \
    -o xattr=sa \
    -o atime=off \
    -o compression=lz4 \
    -o dnodesize=auto \
    -o normalization=formD \
    tank/vm

# Data dataset (optimized for large files)
zfs create -u -o mountpoint=none \
    -o recordsize=1M \
    -o primarycache=all \
    -o logbias=throughput \
    -o acltype=posixacl \
    -o xattr=sa \
    -o atime=off \
    -o compression=lz4 \
    -o dnodesize=auto \
    -o normalization=formD \
    tank/data
```

3. Set mountpoints and mount datasets in order:

```bash
# Set mountpoints - ZFS will automatically mount them with basic options (zfsutil,noatime,xattr)
zfs set mountpoint=/mnt tank/root/nixos
zfs set mountpoint=/mnt/nix tank/nix
zfs set mountpoint=/mnt/nix/store tank/nix/store
zfs set mountpoint=/mnt/boot tank/boot
zfs set mountpoint=/mnt/tank/vm tank/vm
zfs set mountpoint=/mnt/tank/data tank/data

# Mount ESP with specific options
mkdir -p /mnt/boot/efi
mount -t vfat -o fmask=0077,dmask=0077 /dev/disk/by-label/BOOT-EFI /mnt/boot/efi

# Verify mounts
zfs mount
mount | grep -E 'zfs|efi'

# Restore nix store from backup (preserving all attributes and showing progress)
echo "Restoring nix store from backup..."
rsync -avxHAX --progress --numeric-ids --delete /run/media/nixos/obito/backup/nixstore/ /mnt/nix/store/

# Verify the restore
echo "Verifying nix store restore..."
du -sh /mnt/nix/store
ls -la /mnt/nix/store | head -n 5
```

## 4. System Installation

1. Install the system:

```bash
cd ~/code/nepjua
git pull; sudo nixos-install --root /mnt --flake .#kaori
```

1. Set root password when prompted

2. Set final mountpoints:

```bash
# Now set the final mountpoints for when we reboot
# These will mount with basic options (zfsutil,noatime,xattr)
zfs set mountpoint=/ tank/root/nixos
zfs set mountpoint=/nix tank/nix
zfs set mountpoint=/nix/store tank/nix/store
zfs set mountpoint=/boot tank/boot
zfs set mountpoint=/tank/vm tank/vm
zfs set mountpoint=/tank/data tank/data
```

4. Reboot:

```bash
reboot
```

## 5. Post-Installation

After first boot:

1. Verify ZFS status:

```bash
zpool status tank
zfs list
arc_summary
```

2. Create your user account if not done during installation:

```bash
useradd -m -G wheel,libvirtd,kvm your-username
passwd your-username
```

3. Apply ZFS Dataset Optimizations:

```bash
# Root dataset (optimized for OS and small files)
zfs set recordsize=32k tank/root/nixos
zfs set primarycache=all tank/root/nixos
zfs set logbias=latency tank/root/nixos
zfs set sync=disabled tank/root/nixos
zfs set acltype=posixacl tank/root/nixos
zfs set xattr=sa tank/root/nixos
zfs set atime=off tank/root/nixos
zfs set compression=lz4 tank/root/nixos
zfs set dnodesize=auto tank/root/nixos
zfs set normalization=formD tank/root/nixos

# Nix datasets (optimized for package management)
for dataset in tank/nix tank/nix/store; do
    zfs set recordsize=64k $dataset
    zfs set primarycache=all $dataset
    zfs set logbias=latency $dataset
    zfs set sync=disabled $dataset
    zfs set acltype=posixacl $dataset
    zfs set xattr=sa $dataset
    zfs set atime=off $dataset
    zfs set compression=lz4 $dataset
    zfs set dnodesize=auto $dataset
    zfs set normalization=formD $dataset
done

# Boot dataset (optimized for small files)
zfs set recordsize=32k tank/boot
zfs set primarycache=all tank/boot
zfs set logbias=latency tank/boot
zfs set sync=disabled tank/boot
zfs set acltype=posixacl tank/boot
zfs set xattr=sa tank/boot
zfs set atime=off tank/boot
zfs set compression=lz4 tank/boot
zfs set dnodesize=auto tank/boot
zfs set normalization=formD tank/boot

# VM dataset (optimized for VM images and performance)
zfs set recordsize=64k tank/vm
zfs set primarycache=all tank/vm
zfs set logbias=throughput tank/vm
zfs set sync=disabled tank/vm
zfs set acltype=posixacl tank/vm
zfs set xattr=sa tank/vm
zfs set atime=off tank/vm
zfs set compression=lz4 tank/vm
zfs set dnodesize=auto tank/vm
zfs set normalization=formD tank/vm

# Data dataset (optimized for large files)
zfs set recordsize=1M tank/data
zfs set primarycache=all tank/data
zfs set logbias=throughput tank/data
zfs set acltype=posixacl tank/data
zfs set xattr=sa tank/data
zfs set atime=off tank/data
zfs set compression=lz4 tank/data
zfs set dnodesize=auto tank/data
zfs set normalization=formD tank/data

# Verify all settings
for dataset in tank/root/nixos tank/nix tank/nix/store tank/boot tank/vm tank/data; do
    echo "=== $dataset ==="
    zfs get all $dataset | grep -E 'recordsize|primarycache|logbias|sync|acltype|xattr|atime|compression|dnodesize|normalization'
done
```

4. Configure system:

```bash
# Update flake inputs
cd /home/nixos/code/nepjua
nix flake update

# Rebuild system
nixos-rebuild switch --flake .#kaori
```

## 6. Recovery Procedures

If you need to recover or reinstall:

1. Boot from NixOS installation media

2. Import the pool:

```bash
zpool import -N tank
zfs mount tank/root/nixos
zfs mount tank/boot
mount -t vfat /dev/disk/by-label/BOOT-EFI /mnt/boot/efi
```

3. Enter the system:

```bash
nixos-enter --root /mnt
```

## References

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [OpenZFS Documentation](https://openzfs.github.io/openzfs-docs/)
- [NixOS ZFS Wiki](https://nixos.wiki/wiki/ZFS)
