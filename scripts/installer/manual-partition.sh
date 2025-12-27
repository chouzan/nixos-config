#!/usr/bin/env bash
#
# Manual Setup Script
#
# Formats and mounts partitions for NixOS installation.
# This script uses partition LABELS, making it disk-agnostic.
#
# Prerequisites:
#   Create partitions with GParted using these LABELS:
#     - uefi  (512M-1G, EFI System Partition)
#     - boot  (2G)
#     - swap  (RAM + 2GB for hibernation)
#     - root  (100-350G depending on disk size)
#     - home  (remaining space)
#
# Usage:
#   ./manual-setup.sh          # Interactive mode
#   ./manual-setup.sh --check  # Check partitions only
#   ./manual-setup.sh --force  # Skip confirmations

set -euo pipefail

# ─────────────────────────────────────────────────────────────────────────────
# Partition Labels (must match what you create in GParted)
# ─────────────────────────────────────────────────────────────────────────────
LABEL_EFI="uefi"
LABEL_BOOT="boot"
LABEL_SWAP="swap"
LABEL_ROOT="root"
LABEL_HOME="home"

# ─────────────────────────────────────────────────────────────────────────────
# Mount Options (matches disko.nix and storage-future.nix)
# ─────────────────────────────────────────────────────────────────────────────
OPTS_EFI="defaults,fmask=0077,dmask=0077,noatime,nodev,nosuid,noexec"
OPTS_BOOT="defaults,noatime,errors=remount-ro,nodev,nosuid,noexec"
OPTS_BTRFS="defaults,noatime,compress=zstd:3,discard=async,space_cache=v2"

# ─────────────────────────────────────────────────────────────────────────────
# Colors
# ─────────────────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

log_info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn()    { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error()   { echo -e "${RED}[ERROR]${NC} $1"; }
log_step()    { echo -e "\n${CYAN}==>${NC} ${BOLD}$1${NC}"; }

# ─────────────────────────────────────────────────────────────────────────────
# Flags
# ─────────────────────────────────────────────────────────────────────────────
FORCE_MODE=false
CHECK_ONLY=false

for arg in "$@"; do
    case $arg in
        --force)
            FORCE_MODE=true
            ;;
        --check)
            CHECK_ONLY=true
            ;;
        --help|-h)
            cat << 'EOF'
Manual Setup Script

Formats and mounts partitions for NixOS installation using partition LABELS.
This makes it disk-agnostic - works on any disk (NVMe, SATA, etc.)

Usage: ./manual-setup.sh [OPTIONS]

Options:
  --check   Check partitions only (no formatting)
  --force   Skip confirmations
  --help    Show this help

Prerequisites:
  Create partitions in GParted with these LABELS:

  ┌─────────┬────────────────┬────────────────────────────┐
  │ Label   │ Size           │ Notes                      │
  ├─────────┼────────────────┼────────────────────────────┤
  │ uefi    │ 512M - 1G      │ EFI System Partition       │
  │ boot    │ 2G             │ Kernels, initrd            │
  │ swap    │ RAM + 2GB      │ Hibernation support        │
  │ root    │ 100-350G       │ System, /nix/store         │
  │ home    │ Remaining      │ User data                  │
  └─────────┴────────────────┴────────────────────────────┘

  In GParted:
    1. Create GPT partition table (if new disk)
    2. Create partitions with sizes above
    3. Right-click each → "Name Partition" → set label

Filesystem Layout:
  /boot/efi  (vfat)           ← uefi partition
  /boot      (ext4)           ← boot partition
  /          (btrfs, @)       ← root partition
  /home      (btrfs, @home)   ← home partition
EOF
            exit 0
            ;;
        *)
            log_error "Unknown option: $arg"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# ─────────────────────────────────────────────────────────────────────────────
# Helper Functions
# ─────────────────────────────────────────────────────────────────────────────
confirm() {
    if [ "$FORCE_MODE" = true ]; then
        return 0
    fi
    local prompt="$1"
    read -r -p "$(echo -e "${YELLOW}${prompt}${NC}") [y/N]: " response
    case "$response" in
        [yY][eE][sS]|[yY]) return 0 ;;
        *) return 1 ;;
    esac
}

get_partition_by_label() {
    local label="$1"
    local part="/dev/disk/by-partlabel/$label"
    if [ -L "$part" ]; then
        echo "$part"
    else
        echo ""
    fi
}

check_partition() {
    local label="$1"
    local part
    part=$(get_partition_by_label "$label")
    if [ -n "$part" ]; then
        local real_dev
        real_dev=$(readlink -f "$part")
        log_success "$label → $real_dev"
        return 0
    else
        log_error "$label → NOT FOUND"
        return 1
    fi
}

# ─────────────────────────────────────────────────────────────────────────────
# Root Check
# ─────────────────────────────────────────────────────────────────────────────
if [ "$EUID" -ne 0 ]; then
    log_error "This script must be run as root"
    echo "Try: sudo $0"
    exit 1
fi

# ─────────────────────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────────────────────
echo ""
echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║                      Manual Partition Setup                           ║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# ─────────────────────────────────────────────────────────────────────────────
# Check Partitions
# ─────────────────────────────────────────────────────────────────────────────
log_step "Checking partition labels..."

missing=0
for label in "$LABEL_EFI" "$LABEL_BOOT" "$LABEL_SWAP" "$LABEL_ROOT" "$LABEL_HOME"; do
    if ! check_partition "$label"; then
        missing=$((missing + 1))
    fi
done

if [ "$missing" -gt 0 ]; then
    echo ""
    log_error "Missing $missing partition(s)!"
    echo ""
    echo "Create partitions in GParted with these labels:"
    echo "  uefi, boot, swap, root, home"
    echo ""
    echo "To set a partition label in GParted:"
    echo "  Right-click partition → 'Name Partition' → enter label"
    exit 1
fi

log_success "All partitions found"

# Show current layout
echo ""
log_info "Current disk layout:"
lsblk -o NAME,SIZE,TYPE,FSTYPE,LABEL,PARTLABEL,MOUNTPOINT | grep -v loop || true
echo ""

if [ "$CHECK_ONLY" = true ]; then
    log_info "Check complete (--check mode)"
    exit 0
fi

# ─────────────────────────────────────────────────────────────────────────────
# Confirmation
# ─────────────────────────────────────────────────────────────────────────────
echo ""
echo -e "${RED}╔═══════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${RED}║  ⚠️  WARNING: This will FORMAT the following partitions!              ║${NC}"
echo -e "${RED}╚═══════════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "  uefi → $(readlink -f /dev/disk/by-partlabel/uefi)"
echo "  boot → $(readlink -f /dev/disk/by-partlabel/boot)"
echo "  swap → $(readlink -f /dev/disk/by-partlabel/swap)"
echo "  root → $(readlink -f /dev/disk/by-partlabel/root)"
echo "  home → $(readlink -f /dev/disk/by-partlabel/home)"
echo ""

if ! confirm "Are you ABSOLUTELY SURE you want to continue?"; then
    log_info "Aborted by user"
    exit 0
fi

# ─────────────────────────────────────────────────────────────────────────────
# Format Partitions
# ─────────────────────────────────────────────────────────────────────────────
log_step "Formatting partitions..."

PART_EFI="/dev/disk/by-partlabel/$LABEL_EFI"
PART_BOOT="/dev/disk/by-partlabel/$LABEL_BOOT"
PART_SWAP="/dev/disk/by-partlabel/$LABEL_SWAP"
PART_ROOT="/dev/disk/by-partlabel/$LABEL_ROOT"
PART_HOME="/dev/disk/by-partlabel/$LABEL_HOME"

log_info "Formatting EFI partition (vfat)..."
mkfs.vfat -F 32 -n UEFI "$PART_EFI"

log_info "Formatting boot partition (ext4)..."
mkfs.ext4 -F -L BOOT "$PART_BOOT"

log_info "Formatting swap partition..."
mkswap -f -L SWAP "$PART_SWAP"

log_info "Formatting root partition (btrfs)..."
mkfs.btrfs -f -L ROOT "$PART_ROOT"

log_info "Formatting home partition (btrfs)..."
mkfs.btrfs -f -L HOME "$PART_HOME"

log_success "All partitions formatted"

# ─────────────────────────────────────────────────────────────────────────────
# Create Btrfs Subvolumes
# ─────────────────────────────────────────────────────────────────────────────
log_step "Creating btrfs subvolumes..."

log_info "Creating @ subvolume on root..."
mount "$PART_ROOT" /mnt
btrfs subvolume create /mnt/@
umount /mnt

log_info "Creating @home subvolume on home..."
mount "$PART_HOME" /mnt
btrfs subvolume create /mnt/@home
umount /mnt

log_success "Subvolumes created"

# ─────────────────────────────────────────────────────────────────────────────
# Mount Filesystems
# ─────────────────────────────────────────────────────────────────────────────
log_step "Mounting filesystems..."

log_info "Mounting root (/)..."
mount -o "subvol=@,$OPTS_BTRFS" "$PART_ROOT" /mnt

log_info "Creating mount points..."
mkdir -p /mnt/boot/efi /mnt/home

log_info "Mounting boot (/boot)..."
mount -o "$OPTS_BOOT" "$PART_BOOT" /mnt/boot

log_info "Mounting EFI (/boot/efi)..."
mount -o "$OPTS_EFI" "$PART_EFI" /mnt/boot/efi

log_info "Mounting home (/home)..."
mount -o "subvol=@home,$OPTS_BTRFS" "$PART_HOME" /mnt/home

log_info "Enabling swap..."
swapon "$PART_SWAP"

log_success "All filesystems mounted"

# ─────────────────────────────────────────────────────────────────────────────
# Verify
# ─────────────────────────────────────────────────────────────────────────────
log_step "Verifying setup..."

echo ""
echo "Mount points:"
findmnt -R /mnt
echo ""
echo "Swap:"
swapon --show
echo ""

# ─────────────────────────────────────────────────────────────────────────────
# Done
# ─────────────────────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                     ✅ Setup Complete!                                ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "Partitions are formatted and mounted at /mnt"
echo ""
echo "The installer will continue automatically, or run manually:"
echo "  1. Copy/clone config to /mnt/etc/nixos"
echo "  2. nixos-generate-config --root /mnt"
echo "  3. nixos-install --root /mnt --flake /mnt/etc/nixos#<hostname>"
echo ""

exit 0
