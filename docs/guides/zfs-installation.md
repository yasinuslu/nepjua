# NixOS Full ZFS Installation Guide (Flake-Centric, ZFS Boot, systemd-boot)

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

- NixOS installation media (USB drive or ISO image)
- High-performance NVMe drives
- At least 32GB RAM for optimal ZFS caching (64GB+ recommended for heavy
  development)
- Stable internet connection
- Backup of all important data (drives will be completely wiped)

## Installation

The installation process is automated via the `scripts/install/zfs.sh` script.
This script handles:

- Disk partitioning
- ZFS pool creation with optimized settings
- Dataset hierarchy with performance tuning
- ZIL and L2ARC setup
- NixOS installation

### Quick Install

```bash
curl -L -H "Cache-Control: no-cache" \
    https://raw.githubusercontent.com/yasinuslu/nepjua/main/scripts/install/zfs.sh \
    | sudo bash -s -- \
        --disk1 /dev/disk/by-id/nvme-Samsung_SSD_990_PRO_2TB_S6Z2NJ0W445911J \
        --disk2 /dev/disk/by-id/nvme-Viper_VP4300L_4TB_VP4300LFDBA234200458 \
        --hostname kaori \
        --dry-run
```

### Manual Installation

1. Boot from NixOS installation media

2. Clone your flake repository:
   ```bash
   mkdir -p /home/nixos/code
   git clone https://github.com/yasinuslu/nepjua.git /home/nixos/code/nepjua
   ```

3. Run the installation script:
   ```bash
   cd /home/nixos/code/nepjua; git pull; sudo ./scripts/install/zfs.sh \
     --disk1 /dev/disk/by-id/nvme-Samsung_SSD_990_PRO_2TB_S6Z2NJ0W445911J \
     --disk2 /dev/disk/by-id/nvme-Viper_VP4300L_4TB_VP4300LFDBA234200458 \
     --hostname kaori \
     --dry-run
   ```

### Non-destructive Installation

```bash
cd /home/nixos/code/nepjua; git pull; sudo ./scripts/install/zfs.sh \
     --disk1 /dev/disk/by-id/nvme-Samsung_SSD_990_PRO_2TB_S6Z2NJ0W445911J \
     --disk2 /dev/disk/by-id/nvme-Viper_VP4300L_4TB_VP4300LFDBA234200458 \
     --hostname kaori \
     --no-destructive
```

For all available options:

```bash
./scripts/install/zfs.sh --help
```

### Dataset Structure

The script creates an optimized dataset hierarchy:

```plaintext
tank (pool)
├── system/                    # System-related datasets
│   ├── root                  # / (root filesystem)
│   ├── nix                   # /nix
│   │   └── store            # /nix/store
│   ├── var                   # /var
│   └── tmp                   # /tmp
├── user/                     # User-related datasets
│   ├── home                  # /home
│   └── persist              # /persist
└── data/                     # Data-specific datasets
    ├── vm                    # /vm
    └── storage              # /data
```

Each dataset is optimized for its specific use case:

- `/home`: Optimized for development (pnpm, git)
- `/nix/store`: Optimized for package management
- `/vm`: Optimized for VM images
- `/data`: Optimized for large files

## Post-Installation

After installation completes:

1. Set root password on first boot
2. Verify ZFS status:
   ```bash
   zpool status tank
   zfs list
   arc_summary
   ```

## Recovery

If you need to recover or reinstall:

1. Boot from NixOS installation media
2. Import the pool:
   ```bash
   zpool import -N tank
   zfs mount tank/system/root
   mount -t vfat /dev/disk/by-label/BOOT-EFI /boot/efi
   ```

## References

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [OpenZFS Documentation](https://openzfs.github.io/openzfs-docs/)
- [NixOS ZFS Wiki](https://nixos.wiki/wiki/ZFS)

╭───────────────────────────────────────────╮ │ ZFS Installation Summary │
├───────────────────────────────────────────┤ │ Primary Disk: │ │
nvme-Samsung_SSD_990_PRO_2TB │ │ Secondary Disk: │ │ nvme-Viper_VP4300L_4TB │ │
Hostname: kaori │ │ Mode: DRY RUN │
╰───────────────────────────────────────────╯
