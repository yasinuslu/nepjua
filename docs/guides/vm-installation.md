# NixOS VM Installation Guide (Flake-Centric, systemd-boot)

## Hardware Reference Configuration

This guide is intended for virtual machine installations with:

- Single virtual disk (e.g., /dev/vda)
- At least 2GB RAM
- Network connectivity
- UEFI boot support

## Prerequisites

- NixOS installation media (ISO image)
- Virtual machine with UEFI support
- Stable internet connection
- At least 20GB disk space

## Installation

The installation process is automated via the `scripts/install/vm.sh` script.
This script handles:

- Disk partitioning
- Filesystem creation
- NixOS installation with flakes

### Quick Install

```bash
curl -L https://raw.githubusercontent.com/yasinuslu/nepjua/main/scripts/install/vm.sh \
    | sudo bash -s -- \
        --disk /dev/vda \
        --hostname nari \
        --dry-run
```

### Manual Installation

Before running the script, it's recommended to use tmux or screen to prevent
interruptions during installation:

```bash
nix-shell -p tmux --run 'tmux new -s vm-install'
```

1. Boot from NixOS installation media

2. Clone your flake repository:
   ```bash
   mkdir -p /home/nixos/code
   git clone https://github.com/yasinuslu/nepjua.git /home/nixos/code/nepjua
   ```

3. Run the installation script in dry-run mode:
   ```bash
   cd /home/nixos/code/nepjua; git pull; sudo ./scripts/install/vm.sh \
     --disk /dev/vda \
     --hostname nari \
     --dry-run
   ```

4. After verifying the dry-run output, run the installation script without the
   dry-run flag:
   ```bash
   cd /home/nixos/code/nepjua; git pull; sudo ./scripts/install/vm.sh \
     --disk /dev/vda \
     --hostname nari
   ```

### Non-destructive Installation

If you need to rerun the installation script without wiping the disk, use the
`--no-destructive` flag:

```bash
cd /home/nixos/code/nepjua; git pull; sudo ./scripts/install/vm.sh \
     --disk /dev/vda \
     --hostname nari \
     --no-destructive
```

For all available options:

```bash
./scripts/install/vm.sh --help
```

### Partition Structure

The script creates a standard partition layout:

```plaintext
/dev/vda
├── vda1 (512MB)   # EFI System Partition (FAT32)
├── vda2 (4GB)     # Swap partition
└── vda3 (rest)    # Root filesystem (ext4)
```

Mount points:

- `/` - Root filesystem (ext4, labeled "nixos")
- `/boot/efi` - EFI System Partition (FAT32, labeled "EFI")
- `[SWAP]` - Swap partition (labeled "swap")

## Post-Installation

After installation completes:

1. Set root password on first boot
2. Verify system status:
   ```bash
   df -h
   free -h
   ```

## Recovery

If you need to recover or reinstall:

1. Boot from NixOS installation media
2. Mount the filesystems:
   ```bash
   mount /dev/disk/by-label/nixos /mnt
   mkdir -p /mnt/boot/efi
   mount /dev/disk/by-label/EFI /mnt/boot/efi
   swapon /dev/disk/by-label/swap
   ```

## Troubleshooting

### Unable to inform the kernel about the new partitions

If you encounter an error about being unable to inform the kernel of partition
changes:

```plaintext
Error: Partition(s) on /dev/vda have been written, but we have been unable to
inform the kernel of the change, probably because it/they are in use.
```

Reboot the system and try again.

## References

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [NixOS VM Wiki](https://nixos.wiki/wiki/NixOS_in_a_VM)

Example Installation Summary: ╭───────────────────────────────────────────╮ │ VM
Installation Summary │ ├───────────────────────────────────────────┤ │ Disk: │ │
vda │ │ Hostname: nari │ │ Mode: LIVE │ │ Destructive Mode: YES │
├───────────────────────────────────────────┤ │ Mount Points: │ │ /: nixos │ │
/boot/efi: EFI │ ╰───────────────────────────────────────────╯
