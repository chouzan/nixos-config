#!/usr/bin/env bash
#
# NixOS Installation Help
#
# Displays help information and available commands for the installer.
#
# Usage:
#   install-help

cat << 'EOF'
╔═══════════════════════════════════════════════════════════════════════╗
║                      NixOS Configuration Installer                    ║
╚═══════════════════════════════════════════════════════════════════════╝

Quick Start:
  $ sudo menu

The installer will guide you through:
  1. Installation method (disko automated / manual dual-boot)
  2. Host selection (panthera, acinonyx, etc.)
  3. Disk setup, config deployment, and NixOS installation

─────────────────────────────────────────────────────────────────────────
Useful Commands:

  Network:
    $ nmtui                    # Connect to WiFi

  Disks:
    $ lsblk -f                 # List disks and filesystems
    $ sudo gparted             # Partition editor (GUI)

  Manual disko (if needed):
    $ cd /etc/nixos-config
    $ sudo nix run github:nix-community/disko -- \
        --mode destroy,format,mount --dry-run \
        ./hosts/<hostname>/disko.nix

─────────────────────────────────────────────────────────────────────────
Configuration: /etc/nixos-config
Documentation: /etc/nixos-config/docs/
EOF
