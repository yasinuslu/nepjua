#!/usr/bin/env nix-shell
#!nix-shell -i bash -p util-linux parted dosfstools git nixos-install-tools zfs gum
# shellcheck shell=bash

# --- Common variables ---
INSTALL_MNT="/mnt"             # Main mount point for installation
INSTALL_TMP_MNT="/mnt/tmp-install" # Temporary mount point for install-tmp dataset
INSTALL_TMP_DATASET="tank/install-tmp" # ZFS dataset name for temporary files

# --- Strict error handling ---
set -euo pipefail
IFS=$'\n\t'

# --- Color output helpers ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# --- Logging helpers ---
log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_cmd() { echo -e "${BLUE}[CMD]${NC} $1"; }

# --- Function to execute or simulate command ---
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

# --- Function to check if running as root ---
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "This script must be run as root"
        exit 1
    fi
}

# --- Function to validate disk devices exist ---
validate_disks() {
    local disks=("$@")
    for disk in "${disks[@]}"; do
        if [[ ! -e "$disk" ]]; then
            log_error "Disk $disk not found: $disk"
            exit 1
        fi
    done
}

# --- Function to print a summary of the installation ---
print_summary() {
    echo
    echo -e "${BLUE}╭───────────────────────────────────────────╮${NC}"
    echo -e "${BLUE}│${NC}           ${GREEN}ZFS Installation Summary${NC}           ${BLUE}│${NC}"
    echo -e "${BLUE}├───────────────────────────────────────────┤${NC}"
    echo -e "${BLUE}│${NC} Primary Disk:                              ${BLUE}│${NC}"
    echo -e "${BLUE}│${NC}   ${YELLOW}$(basename "$DISK1")${NC}   ${BLUE}│${NC}"
    echo -e "${BLUE}│${NC} Temporary Dataset for /tmp:              ${BLUE}│${NC}"
    echo -e "${BLUE}│${NC}   ${GREEN}${INSTALL_TMP_DATASET}${NC}                            ${BLUE}│${NC}"
    echo -e "${BLUE}│${NC} Mode: ${DRY_RUN:+${YELLOW}DRY RUN${NC}}${DRY_RUN:-${GREEN}LIVE${NC}}                           ${BLUE}│${NC}"
    echo -e "${BLUE}│${NC} Destructive Mode: ${NO_DESTRUCTIVE:+${GREEN}NO${NC}}${NO_DESTRUCTIVE:-${RED}YES${NC}}                     ${BLUE}│${NC}"
    echo -e "${BLUE}╰───────────────────────────────────────────╯${NC}"
    echo
}

# --- Function to confirm destructive action ---
confirm_destruction() {
    local disks=("$@")
    log_warn "This will DESTROY ALL DATA on the following disks:"
    printf '%s\n' "${disks[@]}"

    if [[ "${DRY_RUN:-false}" == "true" ]]; then
        log_info "Dry run mode - no changes will be made"
        return
    fi

    if ! gum confirm --prompt.foreground="#FF0000" "Are you absolutely sure you want to proceed with DESTRUCTIVE actions?" --affirmative="Yes, destroy all data" --negative="No, abort"; then
        log_info "Aborting destructive actions..."
        exit 0
    fi
}

# --- Function to wipe disks ---
wipe_disks() {
    log_info "Wiping disks..."
    execute wipefs -af "$DISK1"
    execute wipefs -af "$DISK2"

    log_info "Forcefully zapping partition tables with sgdisk..."
    execute sgdisk --zap-all -- "/dev/disk/by-id/$(basename "$DISK1")"
    execute sgdisk --zap-all -- "/dev/disk/by-id/$(basename "$DISK2")"

    log_info "Clearing ZFS labels from disks after wipefs and sgdisk..."
    execute zpool labelclear -f "/dev/disk/by-id/$(basename "$DISK1")"
    execute zpool labelclear -f "/dev/disk/by-id/$(basename "$DISK2")"
}

# --- Function to create partitions ---
create_partitions() {
    log_info "Creating partitions..."

    # Primary disk partitioning (DISK1 - System Disk)
    log_info "Partitioning primary disk: $DISK1"
    execute parted -s "$DISK1" -- mklabel gpt
    execute parted -s "$DISK1" -- mkpart ESP fat32 1MiB 1GiB
    execute parted -s "$DISK1" -- set 1 esp on
    execute parted -s "$DISK1" -- mkpart primary 1GiB -32GiB  # Main system partition
    execute parted -s "$DISK1" -- mkpart primary -32GiB 100%  # ZIL partition (optional)

    # Secondary disk partitioning (DISK2 - Data Disk - Optional)
    if [[ -n "$DISK2" ]]; then
        log_info "Partitioning secondary disk: $DISK2"
        execute parted -s "$DISK2" -- mklabel gpt
        execute parted -s "$DISK2" -- mkpart primary 1MiB -500GiB  # Main data partition
        execute parted -s "$DISK2" -- mkpart primary -500GiB 100%  # L2ARC partition (optional)
    fi

    # Format ESP partition
    log_info "Formatting ESP partition on $DISK1-part1"
    execute mkfs.fat -F 32 -n BOOT-EFI "${DISK1}-part1"

    # Set default ZIL and L2ARC partitions if not specified via arguments
    if [[ -z "${ZIL_PART:-}" ]]; then
        ZIL_PART="${DISK1}-part3"
        log_info "Using default ZIL partition: $ZIL_PART"
    fi
    if [[ -z "${L2ARC_PART:-}" ]]; then
        L2ARC_PART="${DISK2}-part2"
        log_info "Using default L2ARC partition: $L2ARC_PART"
    fi
}

# --- Function to create and configure ZFS pool ---
create_zfs_pool() {
    log_info "Creating ZFS pool 'tank'..."

    # Create the pool with base settings (inherited by datasets)
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

    # Add ZIL device (if ZIL partition is defined)
    if [[ -n "$ZIL_PART" ]]; then
        log_info "Adding ZIL device: $ZIL_PART"
        execute zpool labelclear -f "$ZIL_PART" || true # Clear ZIL partition labels
        execute zpool add tank log "$ZIL_PART"
    else
        log_warn "No ZIL partition specified. ZIL is recommended for performance."
    fi

    # Add L2ARC device (if L2ARC partition is defined)
    if [[ -n "$L2ARC_PART" ]]; then
        log_info "Adding L2ARC device: $L2ARC_PART"
        execute zpool add tank cache "$L2ARC_PART"
    else
        log_warn "No L2ARC partition specified. L2ARC is optional cache."
    fi
}

# --- Function to create dataset hierarchy ---
create_datasets() {
    log_info "Creating dataset hierarchy..."

    # Create parent datasets for categories (no mountpoints)
    execute zfs create -o mountpoint=none tank/system
    execute zfs create -o mountpoint=none tank/user
    execute zfs create -o mountpoint=none tank/data

    # System datasets - under tank/system
    execute zfs set recordsize=32K tank/system
    execute zfs create -o mountpoint="${INSTALL_MNT}" tank/system/root   # Mountpoint for / (root)
    execute zfs create -o mountpoint="${INSTALL_MNT}/nix" tank/system/nix
    execute zfs create -o mountpoint="${INSTALL_MNT}/nix/store" \
        -o recordsize=128K \
        -o logbias=throughput \
        -o secondarycache=all \
        tank/system/nix/store
    execute zfs create -o mountpoint="${INSTALL_MNT}/boot" tank/system/boot
    execute zfs create -o mountpoint="${INSTALL_MNT}/var" tank/system/var
    execute zfs create -o mountpoint="${INSTALL_MNT}/tmp" tank/system/tmp

    # User datasets - under tank/user
    execute zfs set recordsize=32K tank/user # Apply recordsize to user category
    execute zfs create -o mountpoint="${INSTALL_MNT}/home" tank/user/home
    execute zfs create -o mountpoint="${INSTALL_MNT}/persist" tank/user/persist

    # Data datasets - under tank/data
    execute zfs set recordsize=1M tank/data
    execute zfs set logbias=throughput tank/data
    execute zfs create -o mountpoint="${INSTALL_MNT}/tank/vm" \
        -o recordsize=128K \
        -o compression=off \
        -o primarycache=metadata \
        -o secondarycache=none \
        tank/data/vm # Mountpoint for /tank/vm
    execute zfs create -o mountpoint="${INSTALL_MNT}/tank/data" \
        -o recordsize=1M \
        tank/data/storage # Mountpoint for /tank/data

    # Temporary dataset for installation - Mountpoint /mnt/tmp-install (temporary)
    log_info "Creating temporary dataset for /tmp: ${INSTALL_TMP_DATASET}"
    execute zfs create -o mountpoint="${INSTALL_TMP_MNT}" "${INSTALL_TMP_DATASET}"
}

# --- Function to mount filesystems ---
mount_mnt() {
    log_info "Mounting filesystems under ${INSTALL_MNT}..."

    # Mount EFI System Partition (ESP)
    log_info "Mounting ESP partition to ${INSTALL_MNT}/boot/efi"
    execute mkdir -p "${INSTALL_MNT}/boot/efi"
    execute mount -t vfat -o fmask=0077,dmask=0077 "${DISK1}-part1" "${INSTALL_MNT}/boot/efi"

    # Mount temporary dataset for /tmp to INSTALL_TMP_MNT (/mnt/tmp-install)
    log_info "Mounting temporary dataset ${INSTALL_TMP_DATASET} to ${INSTALL_TMP_MNT}"
    execute zfs mount "${INSTALL_TMP_DATASET}"

    # Set TMPDIR environment variable to use temporary dataset
    log_info "Setting TMPDIR to ${INSTALL_TMP_MNT}"
    export TMPDIR="${INSTALL_TMP_MNT}"

    # Verify ZFS mounts
    log_info "Verifying ZFS dataset mounts:"
    execute zfs mount

    # Verify all mounts (including non-ZFS)
    log_info "Verifying all mounts:"
    execute mount
}

# --- Function to unmount filesystems ---
unmount_mnt() {
    log_info "Unmounting filesystems under ${INSTALL_MNT}..."
    execute umount -l /mnt/boot/efi || true
    execute umount -l "${INSTALL_TMP_MNT}" || true # Unmount temporary dataset for /tmp
    execute zfs unmount -fa || true
}

# --- Function to set runtime mountpoints (after installation, in target system) ---
set_runtime_mountpoints() {
    log_info "Setting runtime mountpoints for target system..."
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
    log_info "Runtime mountpoints set successfully!"
}

# --- Function to install NixOS ---
install_nixos() {
    log_info "Installing NixOS using nixos-install..."

    GIT_REPO="${GIT_REPO:-https://github.com/yasinuslu/nepjua.git}"
    GIT_BRANCH="${GIT_BRANCH:-main}"
    FLAKE_PATH="${FLAKE_PATH:-/home/nixos/code/nepjua}"
    HOSTNAME="${HOSTNAME:-kaori}"

    log_info "Cloning flake repository from $GIT_REPO (branch: $GIT_BRANCH) to $FLAKE_PATH..."
    execute mkdir -p "$(dirname "$FLAKE_PATH")"
    execute git clone "$GIT_REPO" "$FLAKE_PATH" || true # Ignore error if repo already exists
    execute git -C "$FLAKE_PATH" checkout "$GIT_BRANCH"

    log_info "Running nixos-install (flake: $FLAKE_PATH#$HOSTNAME, root: ${INSTALL_MNT})..."
    execute nixos-install --keep-going --no-channel-copy --root "${INSTALL_MNT}" --flake "$FLAKE_PATH#$HOSTNAME"

    log_info "NixOS installation completed!"
    log_info "Please set root password after first boot in the new system."
}

# --- Function to cleanup temporary dataset after installation ---
cleanup_install_tmp_dataset() {
    log_info "Cleaning up temporary dataset ${INSTALL_TMP_DATASET}..."
    execute zfs unmount "${INSTALL_TMP_DATASET}" || true
    execute zfs destroy "${INSTALL_TMP_DATASET}" || true
    log_info "Temporary dataset ${INSTALL_TMP_DATASET} cleaned up."
}


# --- Function to unmount existing mounts on disks (before installation) ---
unmount_disks() {
    local disks=("$@")

    unmount_mnt # Unmount ZFS and /mnt/boot/efi

    log_info "Unmounting any existing mounts on disks (partitions)..."
    execute umount -l "${INSTALL_TMP_MNT}" 2>/dev/null || true # Try to unmount temporary dataset mountpoint
    for disk in "${disks[@]}"; do
        log_info "Trying to unmount partitions on ${disk}..."
        execute umount -l "${disk}-part1" 2>/dev/null || true
        execute umount -l "${disk}-part2" 2>/dev/null || true
        execute umount -l "${disk}-part3" 2>/dev/null || true
        execute umount -l "${disk}-part4" 2>/dev/null || true
        # Add more partitions if you expect more than 4 partitions to be potentially mounted
    done
    log_info "Existing mounts unmounted (if any)."
}

# --- Function to export ZFS pool ---
export_zfs() {
    log_info "Exporting ZFS pool 'tank'..."
    execute zpool export tank
    log_info "ZFS pool 'tank' exported successfully!"
}

# --- Function to confirm installation before proceeding ---
confirm_installation() {
    log_info "We will now unmount filesystems and start the NixOS installation process."

    if ! gum confirm --prompt.foreground="#FF0000" "Do you want to proceed with the installation?" --affirmative="Yes, proceed" --negative="No, abort"; then
        log_info "Aborting installation as per user request."
        exit 0
    fi

    log_info "Proceeding with installation as confirmed by user."
}

# --- Main script function ---
main() {
    # --- Check if script is running as root ---
    check_root

    # --- Parse command line arguments ---
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
            --git-repo)
                GIT_REPO="$2"
                shift 2
                ;;
            --git-branch)
                GIT_BRANCH="$2"
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
            --no-destructive)
                NO_DESTRUCTIVE=true
                shift
                ;;
            --help)
                echo "Usage: $0 [--dry-run] --disk1 /dev/disk/by-id/nvme-Samsung... [--disk2 /dev/disk/by-id/nvme-Viper...] [--zil /dev/...] [--l2arc /dev/...] [--repo path] [--branch name] [--hostname name]"
                echo
                echo "Options:"
                echo "  --disk1             Primary disk for the ZFS pool (required)"
                echo "  --disk2             Secondary disk to add to the ZFS pool (optional)"
                echo "  --zil               ZFS Intent Log partition (recommended)"
                echo "  --l2arc             L2ARC cache partition (optional)"
                echo "  --repo              Path to flake repository (default: https://github.com/yasinuslu/nepjua.git)"
                echo "  --branch            Git branch to use (default: main)"
                echo "  --hostname          NixOS hostname (default: kaori)"
                echo "  --dry-run           Show commands without executing them"
                echo "  --no-destructive    Skip disk wiping, partitioning and ZFS pool creation. Assumes existing ZFS setup."
                echo "  --help              Show this help message"
                exit 0
                ;;
            *)
                log_error "Unknown parameter: $1"
                exit 1
                ;;
        esac
    done

    # --- Validate required parameters and disks ---
    if [[ -z "${DISK1:-}" ]]; then
        log_error "--disk1 (Primary Disk) is required"
        exit 1
    fi
    validate_disks "$DISK1"
    [[ -n "${DISK2:-}" ]] && validate_disks "$DISK2" # Validate DISK2 only if provided
    [[ -n "${ZIL_PART:-}" ]] && validate_disks "$ZIL_PART"
    [[ -n "${L2ARC_PART:-}" ]] && validate_disks "$L2ARC_PART"

    # --- Print installation summary ---
    print_summary

    # --- Handle dry-run mode ---
    if [[ "${DRY_RUN:-false}" == "true" ]]; then
        log_info "DRY RUN MODE - Commands will be shown but not executed. No changes will be made."
    else
        confirm_installation # Ask user for confirmation in live mode
    fi

    log_info "--- Starting ZFS Installation Process ---"

    # --- Unmount any existing mounts on the disks ---
    unmount_disks "$DISK1" "$DISK2"

    # --- Execute installation steps (unless --no-destructive) ---
    if [[ "${NO_DESTRUCTIVE:-false}" == "false" ]]; then
        confirm_destruction "$DISK1" "$DISK2" # Ask for destructive action confirmation
        wipe_disks          # Wipe disk signatures and labels
        create_partitions     # Create GPT partitions
        create_zfs_pool       # Create ZFS pool 'tank'
        create_datasets       # Create ZFS dataset hierarchy
    else
        log_info "NON-DESTRUCTIVE MODE - Skipping disk wiping, partitioning, and ZFS pool creation."
        log_info "Assuming existing ZFS pool 'tank' and datasets are correctly set up."
    fi

    mount_mnt           # Mount ZFS datasets and ESP to /mnt
    install_nixos       # Install NixOS using nixos-install
    unmount_mnt         # Unmount filesystems from /mnt

    cleanup_install_tmp_dataset # Cleanup temporary dataset after install_nixos

    set_runtime_mountpoints # Set ZFS mountpoints for the target system
    export_zfs            # Export the ZFS pool 'tank'

    log_info "--- Installation completed successfully! ---"
    log_info "You can now reboot into your new NixOS system."
    log_info "Please remember to set the root password after the first boot."
}

# --- Run main function with command line arguments ---
main "$@" 
