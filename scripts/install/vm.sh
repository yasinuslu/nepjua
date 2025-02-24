#!/usr/bin/env nix-shell
#!nix-shell -i bash -p util-linux parted dosfstools git nixos-install-tools gum
# shellcheck shell=bash

# Common variables
INSTALL_MNT="/mnt"

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
    local disk="$1"
    if [[ ! -e "$disk" ]]; then
        log_error "Disk $disk not found"
        exit 1
    fi
}

# Print a beautiful summary of what we're going to do
print_summary() {
    echo
    echo -e "${BLUE}╭───────────────────────────────────────────╮${NC}"
    echo -e "${BLUE}│${NC}           ${GREEN}VM Installation Summary${NC}           ${BLUE}│${NC}"
    echo -e "${BLUE}├───────────────────────────────────────────┤${NC}"
    echo -e "${BLUE}│${NC} Disk:                                     ${BLUE}│${NC}"
    echo -e "${BLUE}│${NC}   ${YELLOW}$(basename "$DISK")${NC}   ${BLUE}│${NC}"
    echo -e "${BLUE}│${NC} Hostname: ${YELLOW}$HOSTNAME${NC}                         ${BLUE}│${NC}"
    echo -e "${BLUE}│${NC} Mode: ${DRY_RUN:+${YELLOW}DRY RUN${NC}}${DRY_RUN:-${GREEN}LIVE${NC}}                           ${BLUE}│${NC}"
    echo -e "${BLUE}│${NC} Destructive Mode: ${NO_DESTRUCTIVE:+${GREEN}NO${NC}}${NO_DESTRUCTIVE:-${RED}YES${NC}}                     ${BLUE}│${NC}"
    echo -e "${BLUE}├───────────────────────────────────────────┤${NC}"
    echo -e "${BLUE}│${NC} Mount Points:                             ${BLUE}│${NC}"
    echo -e "${BLUE}│${NC}   /:          ${YELLOW}nixos${NC}                         ${BLUE}│${NC}"
    echo -e "${BLUE}│${NC}   /boot/efi:  ${YELLOW}EFI${NC}                          ${BLUE}│${NC}"
    echo -e "${BLUE}╰───────────────────────────────────────────╯${NC}"
    echo
}

# Function to confirm destructive action
confirm_destruction() {
    local disk="$1"
    log_warn "This will DESTROY ALL DATA on the following disk:"
    echo "$disk"

    if [[ "${DRY_RUN:-false}" == "true" ]]; then
        log_info "Dry run mode - no changes will be made"
        return
    fi

    if ! gum confirm --prompt.foreground="#FF0000" "Are you absolutely sure you want to proceed with DESTRUCTIVE actions?" --affirmative="Yes, destroy all data" --negative="No, abort"; then
        log_info "Aborting destructive actions..."
        exit 0
    fi
}

# Function to wipe disk
wipe_disk() {
    log_info "Wiping disk..."
    execute wipefs -af "$DISK"
    execute sgdisk --zap-all "$DISK"
}

# Function to create partitions
create_partitions() {
    log_info "Creating partitions..."
    
    # Check if we're in UEFI mode
    local is_uefi=false
    if [ -d "/sys/firmware/efi" ]; then
        is_uefi=true
        log_info "Detected UEFI system"
    else
        log_info "Detected BIOS system"
    fi
    
    # Create partitions
    execute parted -s "$DISK" -- mklabel gpt
    
    if [ "$is_uefi" = true ]; then
        # UEFI partitioning
        execute parted -s "$DISK" -- mkpart ESP fat32 1MiB 512MiB
        execute parted -s "$DISK" -- set 1 esp on
        execute parted -s "$DISK" -- mkpart primary 512MiB 4.5GiB
        execute parted -s "$DISK" -- mkpart primary 4.5GiB 100%
    else
        # BIOS partitioning
        execute parted -s "$DISK" -- mkpart primary 1MiB 2MiB  # BIOS boot partition
        execute parted -s "$DISK" -- set 1 bios_grub on
        execute parted -s "$DISK" -- mkpart primary 2MiB 4.5GiB  # Swap partition
        execute parted -s "$DISK" -- mkpart primary 4.5GiB 100%  # Root partition
    fi
    
    # Wait a moment for the kernel to recognize the new partitions
    sleep 2
    
    # Format partitions
    if [ "$is_uefi" = true ]; then
        execute mkfs.fat -F 32 -n "EFI" "${DISK}1"
        execute mkswap -L "swap" "${DISK}2"
        execute mkfs.ext4 -F -L "nixos" "${DISK}3"
    else
        # First partition is BIOS boot, no formatting needed
        execute mkswap -L "swap" "${DISK}2"
        execute mkfs.ext4 -F -L "nixos" "${DISK}3"
    fi
}

# Function to mount filesystems
mount_filesystems() {
    log_info "Mounting filesystems..."
    local is_uefi=false
    if [ -d "/sys/firmware/efi" ]; then
        is_uefi=true
    fi

    # Try mounting by label first, fall back to device names if labels don't exist
    if [[ -e /dev/disk/by-label/nixos ]]; then
        execute mount /dev/disk/by-label/nixos "$INSTALL_MNT"
    else
        execute mount "${DISK}3" "$INSTALL_MNT"
    fi

    if [ "$is_uefi" = true ]; then
        execute mkdir -p "$INSTALL_MNT/boot/efi"
        if [[ -e /dev/disk/by-label/EFI ]]; then
            execute mount /dev/disk/by-label/EFI "$INSTALL_MNT/boot/efi"
        else
            execute mount "${DISK}1" "$INSTALL_MNT/boot/efi"
        fi
    fi

    if [[ -e /dev/disk/by-label/swap ]]; then
        execute swapon /dev/disk/by-label/swap
    else
        execute swapon "${DISK}2"
    fi
}

# Function to unmount filesystems
unmount_filesystems() {
    log_info "Unmounting filesystems..."
    execute swapoff /dev/disk/by-label/swap || true
    execute umount -R "$INSTALL_MNT" || true
}

# Function to install NixOS
install_nixos() {
    log_info "Installing NixOS..."

    GIT_REPO="${GIT_REPO:-https://github.com/yasinuslu/nepjua.git}"
    GIT_BRANCH="${GIT_BRANCH:-main}"
    FLAKE_PATH="${FLAKE_PATH:-/home/nixos/code/nepjua}"

    # Create directory and clone repository
    execute mkdir -p "$(dirname "$FLAKE_PATH")"
    execute git clone "$GIT_REPO" "$FLAKE_PATH" || true
    execute git -C "$FLAKE_PATH" checkout "$GIT_BRANCH"

    # Install NixOS using the flake
    execute nixos-install \
        --keep-going \
        --no-channel-copy \
        --no-bootloader \
        --root "${INSTALL_MNT}" \
        --flake "$FLAKE_PATH#$HOSTNAME"

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
            --disk)
                DISK="$2"
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
                echo "Usage: $0 [--dry-run] --disk /dev/vda [--repo path] [--branch name] [--hostname name]"
                echo
                echo "Options:"
                echo "  --disk              Disk to install NixOS on"
                echo "  --repo              Path to flake repository (default: /home/nixos/code/nepjua)"
                echo "  --branch            Git branch to use (default: main)"
                echo "  --hostname          NixOS hostname"
                echo "  --dry-run           Show commands without executing them"
                echo "  --no-destructive    Skip disk wiping and partitioning"
                echo "  --help              Show this help message"
                exit 0
                ;;
            *)
                log_error "Unknown parameter: $1"
                exit 1
                ;;
        esac
    done

    # Validate required parameters
    if [[ -z "${DISK:-}" ]]; then
        log_error "--disk is required"
        exit 1
    fi

    if [[ -z "${HOSTNAME:-}" ]]; then
        log_error "--hostname is required"
        exit 1
    fi

    [[ "${DRY_RUN:-false}" == "true" ]] && log_info "DRY RUN MODE - Commands will be shown but not executed"

    log_info "Starting VM installation..."
    
    # Validate disk exists
    validate_disks "$DISK"

    # Unmount any existing mounts
    unmount_filesystems

    # Execute installation steps
    if [[ "${NO_DESTRUCTIVE:-false}" == "false" ]]; then
        confirm_destruction "$DISK"
        wipe_disk
        create_partitions
    else
        log_info "NON-DESTRUCTIVE MODE - Skipping disk wiping and partitioning"
    fi

    mount_filesystems

    if [[ "${DRY_RUN:-false}" == "true" ]]; then
        print_summary
        log_info "DRY RUN MODE - Commands will be shown but not executed"
    else
        print_summary
        if ! gum confirm --prompt.foreground="#FF0000" "Do you want to proceed with the installation?" --affirmative="Yes, proceed" --negative="No, abort"; then
            log_info "Aborting installation..."
            exit 0
        fi
    fi

    install_nixos

    unmount_filesystems

    log_info "Installation completed successfully!"
    log_info "You can now reboot into your new system"
}

# Run main function with all arguments
main "$@" 
