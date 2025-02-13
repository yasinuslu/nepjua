#!/usr/bin/env nix-shell
#!nix-shell -i bash -p util-linux parted dosfstools git nixos-install-tools zfs gum
# shellcheck shell=bash

# Strict error handling
set -euo pipefail
IFS=$'\n\t'

# Color output helpers
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging helpers
log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_cmd() { echo -e "${BLUE}[CMD]${NC} $1"; }

# Function to execute or simulate command
execute() {
    local cmd_str
    cmd_str=$(printf '%q ' "$@")
    if [[ "${DRY_RUN:-false}" == "true" ]]; then
        log_cmd "${cmd_str% }"  # Remove trailing space
    else
        log_cmd "${cmd_str% }"  # Remove trailing space
        "$@"
    fi
}

# Function to check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "This script must be run as root"
        exit 1
    fi
}

# Function to validate disk devices exist
validate_disks() {
    local disks=("$@")
    for disk in "${disks[@]}"; do
        if [[ ! -e "$disk" ]]; then
            log_error "Disk $disk not found"
            exit 1
        fi
    done
}

# Print a beautiful summary of what we're going to do
print_summary() {
    echo
    echo -e "${BLUE}╭───────────────────────────────────────────╮${NC}"
    echo -e "${BLUE}│${NC}           ${GREEN}ZFS Installation Summary${NC}           ${BLUE}│${NC}"
    echo -e "${BLUE}├───────────────────────────────────────────┤${NC}"
    echo -e "${BLUE}│${NC} Primary Disk:                              ${BLUE}│${NC}"
    echo -e "${BLUE}│${NC}   ${YELLOW}$(basename "$DISK1")${NC}   ${BLUE}│${NC}"
    echo -e "${BLUE}│${NC} Secondary Disk:                            ${BLUE}│${NC}"
    echo -e "${BLUE}│${NC}   ${YELLOW}$(basename "$DISK2")${NC}   ${BLUE}│${NC}"
    echo -e "${BLUE}│${NC} Hostname: ${YELLOW}$HOSTNAME${NC}                         ${BLUE}│${NC}"
    echo -e "${BLUE}│${NC} Mode: ${DRY_RUN:+${YELLOW}DRY RUN${NC}}${DRY_RUN:-${GREEN}LIVE${NC}}                           ${BLUE}│${NC}"
    echo -e "${BLUE}╰───────────────────────────────────────────╯${NC}"
    echo
}

# Function to confirm destructive action
confirm_destruction() {
    local disks=("$@")
    print_summary
    log_warn "This will DESTROY ALL DATA on the following disks:"
    printf '%s\n' "${disks[@]}"
    if [[ "${DRY_RUN:-false}" == "true" ]]; then
        log_info "Dry run mode - no changes will be made"
        return
    fi
    
    if ! command -v gum >/dev/null 2>&1; then
        log_info "Installing gum for interactive confirmation..."
        execute curl -fsSL https://gum.charm.sh/install.sh | execute bash 2>/dev/null
    fi

    if ! gum confirm --prompt.foreground="#FF0000" "Are you absolutely sure you want to proceed?" --affirmative="Yes, destroy all data" --negative="No, abort"; then
        log_info "Aborting..."
        exit 0
    fi
}

# Function to wipe disks
wipe_disks() {
    log_info "Wiping disks..."
    execute wipefs -af "$DISK1"
    execute wipefs -af "$DISK2"
}

# Function to create partitions
create_partitions() {
    log_info "Creating partitions..."
    
    # Primary disk partitioning
    execute parted -s "$DISK1" -- mklabel gpt
    execute parted -s "$DISK1" -- mkpart ESP fat32 1MiB 1GiB
    execute parted -s "$DISK1" -- set 1 esp on
    execute parted -s "$DISK1" -- mkpart primary 1GiB -32GiB  # Main partition
    execute parted -s "$DISK1" -- mkpart primary -32GiB 100%  # ZIL partition
    
    # Secondary disk partitioning
    execute parted -s "$DISK2" -- mklabel gpt
    execute parted -s "$DISK2" -- mkpart primary 1MiB -500GiB  # Main partition
    execute parted -s "$DISK2" -- mkpart primary -500GiB 100%  # L2ARC partition
    
    # Format ESP
    execute mkfs.fat -F 32 -n BOOT-EFI "${DISK1}-part1"

    # Set default ZIL and L2ARC partitions if not specified
    if [[ -z "${ZIL_PART:-}" ]]; then
        ZIL_PART="${DISK1}-part3"
        log_info "Using default ZIL partition: $ZIL_PART"
    fi

    if [[ -z "${L2ARC_PART:-}" ]]; then
        L2ARC_PART="${DISK2}-part2"
        log_info "Using default L2ARC partition: $L2ARC_PART"
    fi
}

# Function to create and configure ZFS pool
create_zfs_pool() {
    log_info "Creating ZFS pool..."
    
    # Create the pool with base settings that will be inherited by all datasets
    execute zpool create -f -o ashift=12 \
        -O mountpoint=none \
        -O acltype=posixacl \
        -O compression=lz4 \
        -O atime=off \
        -O xattr=sa \
        -O dnodesize=auto \
        -O normalization=formD \
        -O sync=standard \
        -O primarycache=all \
        tank "${DISK1}-part2" "${DISK2}-part1"

    # Add ZIL device
    log_info "Adding ZIL device..."
    execute zpool add tank log "$ZIL_PART"

    # Add L2ARC device
    log_info "Adding L2ARC device..."
    execute zpool add tank cache "$L2ARC_PART"
}

# Function to create dataset hierarchy
create_datasets() {
    log_info "Creating dataset hierarchy..."

    # Define base mount point for installation
    INSTALL_MNT="/mnt"

    # Create parent datasets for categories
    execute zfs create -o mountpoint=none tank/system
    execute zfs create -o mountpoint=none tank/user
    execute zfs create -o mountpoint=none tank/data

    # System datasets - under tank/system
    execute zfs set recordsize=32K tank/system

    # Root dataset
    execute zfs create -o mountpoint="${INSTALL_MNT}" tank/system/root

    # Nix datasets
    execute zfs create -o mountpoint="${INSTALL_MNT}/nix" tank/system/nix
    execute zfs create -o mountpoint="${INSTALL_MNT}/nix/store" \
        -o recordsize=128K \
        -o logbias=throughput \
        -o secondarycache=all \
        tank/system/nix/store

    # Boot dataset
    execute zfs create -o mountpoint="${INSTALL_MNT}/boot" tank/system/boot

    # Var directory
    execute zfs create -o mountpoint="${INSTALL_MNT}/var" tank/system/var

    # Tmp directory
    execute zfs create -o mountpoint="${INSTALL_MNT}/tmp" tank/system/tmp

    # User datasets - under tank/user
    execute zfs set recordsize=32K tank/user # Apply recordsize to user category

    # Home directory
    execute zfs create -o mountpoint="${INSTALL_MNT}/home" tank/user/home

    # Persist directory
    execute zfs create -o mountpoint="${INSTALL_MNT}/persist" tank/user/persist

    # Data datasets - under tank/data
    execute zfs set recordsize=1M tank/data
    execute zfs set logbias=throughput tank/data

    # VM dataset - MOUNT UNDER /mnt/tank during installation
    execute zfs create -o mountpoint="${INSTALL_MNT}/tank/vm" \
        -o recordsize=128K \
        -o compression=off \
        -o primarycache=metadata \
        -o secondarycache=none \
        tank/data/vm

    # General storage - MOUNT UNDER /mnt/tank during installation
    execute zfs create -o mountpoint="${INSTALL_MNT}/tank/data" \
        -o recordsize=1M \
        tank/data/storage
}

# Function to mount filesystems
mount_filesystems() {
    log_info "Mounting filesystems..."
    
    INSTALL_MNT="/mnt"

    # Create EFI mount point and mount
    execute mkdir -p "${INSTALL_MNT}/boot/efi"
    execute mount -t vfat -o fmask=0077,dmask=0077 "${DISK1}-part1" "${INSTALL_MNT}/boot/efi"
    
    # Verify mounts
    execute zfs mount
    execute mount | grep -E 'zfs|efi'
}

# Function to unmount filesystems
unmount_filesystems() {
    log_info "Unmounting filesystems..."
    execute zfs unmount
    execute umount -l /boot/efi
}

# Function to set runtime mountpoints
set_runtime_mountpoints() {
    log_info "Setting runtime mountpoints..."
    execute zfs set mountpoint=/ tank/system/root
    execute zfs set mountpoint=/nix tank/system/nix
    execute zfs set mountpoint=/nix/store tank/system/nix/store
    execute zfs set mountpoint=/boot tank/system/boot
    execute zfs set mountpoint=/var tank/system/var
    execute zfs set mountpoint=/tmp tank/system/tmp
    execute zfs set mountpoint=/home tank/user/home
    execute zfs set mountpoint=/persist tank/user/persist
    execute zfs set mountpoint=/tank/vm tank/data/vm
    execute zfs set mountpoint=/tank/data tank/data/storage
}

# Function to install NixOS
install_nixos() {
    log_info "Installing NixOS..."

    # Set defaults
    REPO="${REPO:-/home/nixos/code/nepjua}"
    BRANCH="${BRANCH:-main}"
    HOSTNAME="${HOSTNAME:-kaori}"
    INSTALL_MNT="/mnt"

    # Create directory and clone repository
    execute mkdir -p "$(dirname "$REPO")"
    execute git clone https://github.com/yasinuslu/nepjua.git "$REPO"
    execute git -C "$REPO" checkout "$BRANCH"

    # Install NixOS using the flake
    execute nixos-install --root "${INSTALL_MNT}" --flake "$REPO#$HOSTNAME" --no-root-passwd

    log_info "NixOS installation completed!"
    log_info "Please set root password after first boot"
}

# Main script starts here
main() {
    # Check if running as root
    check_root

    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --disk1)
                DISK1="$2"
                shift 2
                ;;
            --disk2)
                DISK2="$2"
                shift 2
                ;;
            --zil)
                ZIL_PART="$2"
                shift 2
                ;;
            --l2arc)
                L2ARC_PART="$2"
                shift 2
                ;;
            --repo)
                REPO="$2"
                shift 2
                ;;
            --branch)
                BRANCH="$2"
                shift 2
                ;;
            --hostname)
                HOSTNAME="$2"
                shift 2
                ;;
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --help)
                echo "Usage: $0 [--dry-run] --disk1 /dev/disk/by-id/nvme-Samsung... --disk2 /dev/disk/by-id/nvme-Viper... [--zil /dev/...] [--l2arc /dev/...] [--repo path] [--branch name] [--hostname name]"
                echo
                echo "Options:"
                echo "  --disk1     Primary disk (faster NVMe) for the ZFS pool"
                echo "  --disk2     Secondary disk for the ZFS pool"
                echo "  --zil       ZFS Intent Log partition (recommended)"
                echo "  --l2arc     L2ARC cache partition (optional)"
                echo "  --repo      Path to flake repository (default: /home/nixos/code/nepjua)"
                echo "  --branch    Git branch to use (default: main)"
                echo "  --hostname  NixOS hostname (default: kaori)"
                echo "  --dry-run   Show commands without executing them"
                echo "  --help      Show this help message"
                exit 0
                ;;
            *)
                log_error "Unknown parameter: $1"
                exit 1
                ;;
        esac
    done

    # Validate required parameters
    if [[ -z "${DISK1:-}" ]] || [[ -z "${DISK2:-}" ]]; then
        log_error "Both --disk1 and --disk2 are required"
        exit 1
    fi

    # Validate disks exist
    validate_disks "$DISK1" "$DISK2"
    [[ -n "${ZIL_PART:-}" ]] && validate_disks "$ZIL_PART"
    [[ -n "${L2ARC_PART:-}" ]] && validate_disks "$L2ARC_PART"

    # Confirm destruction
    confirm_destruction "$DISK1" "$DISK2"

    log_info "Starting ZFS installation..."
    [[ "${DRY_RUN:-false}" == "true" ]] && log_info "DRY RUN MODE - Commands will be shown but not executed"

    # Execute installation steps
    wipe_disks
    create_partitions
    create_zfs_pool
    create_datasets
    mount_filesystems
    install_nixos
    unmount_filesystems
    set_runtime_mountpoints

    log_info "Installation completed successfully!"
    log_info "You can now reboot into your new system"
}

# Run main function with all arguments
main "$@" 
