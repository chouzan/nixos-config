# Partitioning Guide

Installation procedures for disk setup and partitioning.

**For architecture and rationale, see:** `STORAGE_DESIGN.md`

---

## Overview

This configuration supports two installation approaches:

- **Dual-Boot Setup** - Semi-automated installation with manual partitioning for safety
- **Single-Boot Setup** - Fully automated installation using disko for complete disk management

The approach you choose depends on your system requirements and risk tolerance.

**Note:** Disko reformats the **entire target disk**, making it unsuitable for dual-booting on the same drive. However, dual-booting is possible when NixOS and other operating systems use separate physical drives.

---

# Dual-Boot Setup (Semi-Automated)

## Summary

**Method:** Semi-automated installation
**Automation:** Custom installer ISO with setup script
**Safety:** Manual partitioning prevents accidental data loss

## Partition Layout

```
Linux partitions (create in unallocated space):
├── p5 - /boot/efi (512M-1G, vfat)
├── p6 - /boot (1-2G, ext4)
├── p7 - swap (RAM + 2GB)
├── p8 - / (btrfs, @ subvolume)
└── p9 - /home (btrfs, @home subvolume)
```

**Configuration Files:**
- `hosts/<hostname>/storage.nix` - Current configuration
- `hosts/<hostname>/storage-future.nix` - Target configuration (matches this guide)

## Installation Method

**Manual:** Create partitions (safety)
**Automated:** Format, mount, subvolume creation

**Tools:**
- `hosts/<hostname>/installer-iso.nix` - Custom installer with embedded scripts
- `hosts/<hostname>/setup-dual-boot.sh` - Format and mount automation
- `hosts/<hostname>/storage-future.nix` - Mount point declarations

## Build Installer ISO

```bash
nix run github:nix-community/nixos-generators -- \
  --format install-iso \
  --configuration ./hosts/<hostname>/installer-iso.nix \
  -o <hostname>-installer
```

## Installation Steps

1. **Prepare System**
   - Disable Secure Boot in BIOS
   - Shrink existing partitions if needed
   - Create unallocated space

2. **Boot Installer**
   - Boot from custom ISO
   - Instructions appear on screen

3. **Create Partitions**
   ```bash
   sudo gparted
   # Create 5 partitions with labels: uefi, boot, swap, root, home
   ```

4. **Verify and Format**
   ```bash
   setup-<hostname> --check
   sudo setup-<hostname>
   ```

5. **Install**
   ```bash
   cd /mnt/etc
   sudo cp -r /etc/nixos-config nixos
   cd nixos
   sudo nixos-generate-config --root /mnt
   sudo nixos-install --root /mnt --flake .#<hostname>
   ```

---

# Single-Boot Setup (Fully Automated)

## Summary

**Method:** Fully automated with disko
**Configuration:** `hosts/<hostname>/disko.nix`

## ⚠️ Safety & Preparation

**CRITICAL WARNINGS:**
- Disko **WILL DESTROY ALL DATA** on the target disk
- Disko **REFORMATS THE ENTIRE DISK** - not suitable for dual-boot on same drive
- **NO UNDO** - all existing partitions and data will be permanently lost
- Verify target disk identifier before running any commands
- **DO NOT** run on a disk containing important data

**Preparation Steps:**

1. **Backup Critical Data**
   - Backup all important files from the target system
   - Verify backups are accessible and complete

2. **Verify Target Disk**
   ```bash
   # List all disks and their identifiers
   lsblk -f
   sudo fdisk -l

   # Find disk by ID (recommended for disko.nix)
   ls -la /dev/disk/by-id/
   ```

3. **Update disko.nix Configuration**
   ```bash
   # Edit hosts/<hostname>/disko.nix and set correct device:
   # device = "/dev/disk/by-id/ata-YourActualDisk-SerialNumber";
   ```

4. **Test Configuration**
   ```bash
   # Validate disko configuration syntax
   nix eval .#nixosConfigurations.<hostname>.config.disko.devices --show-trace
   ```

## Installation

### Method 1: Two-Step Process (Manual Control)

```bash
# Step 1: Test the configuration (ALWAYS RUN THIS FIRST)
sudo nix run github:nix-community/disko -- \
  --mode destroy,format,mount \
  --dry-run \
  ./hosts/<hostname>/disko.nix

# Step 2: Apply the disk configuration
# ⚠️  LAST CHANCE TO ABORT - ALL DATA WILL BE LOST AFTER THIS COMMAND
sudo nix run github:nix-community/disko -- \
  --mode destroy,format,mount \
  ./hosts/<hostname>/disko.nix

# Step 3: Install NixOS
sudo nixos-install --flake .#<hostname>
```

### Method 2: One-Command Installation (Streamlined)

```bash
# Single command that handles both partitioning and installation
# ⚠️  THIS WILL DESTROY ALL DATA - VERIFY TARGET DISK FIRST
sudo nix run github:nix-community/disko -- disko-install \
  --flake .#<hostname> \
  --mode format

# For automation (skips all safety prompts - USE WITH EXTREME CAUTION):
# sudo nix run github:nix-community/disko -- disko-install \
#   --flake .#<hostname> \
#   --mode format \
#   --yes-wipe-all-disks
```

**When to use each method:**
- **Method 1**: First-time setup, debugging, or when you need control over each step
- **Method 2**: Routine reinstalls or automated deployments (after testing with Method 1)

### Alternative Modes

- `--mode format` - Format and mount only (preserves existing partitions if compatible)
- `--mode mount` - Mount existing filesystems only (for system updates)
- `--mode destroy,format,mount` - Complete disk recreation (equivalent to old `--mode disko`)

---

## Configuration Files

**Documentation:**
- `docs/STORAGE_DESIGN.md` - Architecture and rationale
- `docs/PARTITIONING.md` - Installation procedures (this document)
- `docs/TROUBLESHOOTING.md` - Common issues and solutions

**Dual-Boot Setup:**
- `hosts/<hostname>/setup-dual-boot.sh` - Format/mount script
- `hosts/<hostname>/installer-iso.nix` - Custom ISO
- `hosts/<hostname>/storage-future.nix` - Mount declarations

**Single-Boot Setup:**
- `hosts/<hostname>/disko.nix` - Automated disk setup (⚠️ verify device identifier before use)
- `hosts/<hostname>/configuration.nix` - System configuration

## Example disko.nix Configuration

```nix
{ ... }:

{
  disko.devices = {
    disk = {
      main = {
        # ⚠️  CRITICAL: VERIFY TARGET DISK BEFORE RUNNING DISKO ⚠️
        #
        # RECOMMENDED: Use stable disk identifiers (by-id):
        # device = "/dev/disk/by-id/ata-Samsung_SSD_850_EVO_250GB_S21NNSAF123456L";
        #
        # To find your disk identifier:
        #   ls -la /dev/disk/by-id/
        #   lsblk -f
        #   sudo fdisk -l
        device = "/dev/sda"; # ⚠️  CHANGE THIS TO YOUR ACTUAL DISK

        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            uefi = {
              label = "uefi";
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot/efi";
                mountOptions = [ "defaults" "fmask=0077" "dmask=0077" "noatime" "nodev" "nosuid" "noexec" ];
              };
            };
            boot = {
              label = "boot";
              size = "2G";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/boot";
                mountOptions = [ "defaults" "noatime" "errors=remount-ro" "nodev" "nosuid" "noexec" ];
              };
            };
            swap = {
              label = "swap";
              size = "18G"; # Adjust: RAM + 2GB for hibernation
              content = {
                type = "swap";
                randomEncryption = false; # Required for hibernation
              };
            };
            root = {
              label = "root";
              size = "200G"; # Adjust based on disk size
              content = {
                type = "btrfs";
                subvolumes = {
                  "@" = {
                    mountpoint = "/";
                    mountOptions = [ "defaults" "noatime" "compress=zstd:3" "discard=async" "space_cache=v2" ];
                  };
                };
              };
            };
            home = {
              label = "home";
              size = "100%"; # Use remaining space
              content = {
                type = "btrfs";
                subvolumes = {
                  "@home" = {
                    mountpoint = "/home";
                    mountOptions = [ "defaults" "noatime" "compress=zstd:3" "discard=async" "space_cache=v2" ];
                  };
                };
              };
            };
          };
        };
      };
    };
  };

  boot.tmp.useTmpfs = true;
}
```

## Troubleshooting

**Common Issues:**
- **Device not found:** Update device identifier in `disko.nix` - see preparation steps above
- **Permission denied:** Ensure running with `sudo`
- **Nix evaluation errors:** Run with `--show-trace` flag for detailed error messages
- **USB wake issues:** See `docs/TROUBLESHOOTING.md` for post-installation fixes

**Getting Help:**
- Disko documentation: https://github.com/nix-community/disko
- NixOS manual: https://nixos.org/manual/nixos/stable/
