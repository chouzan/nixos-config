# Leopardus - NixOS Installer ISO

Bootable installer ISO supporting multiple hosts and installation methods.

## Build

```bash
nix build .#installer -o out
# or: nix build .#leopardus -o out
```

The ISO will be at `out/iso/nixos-minimal-<version>-x86_64-linux.iso`.

## Usage

1. Write to USB:
   ```bash
   sudo dd if=out/iso/*.iso of=/dev/sdX bs=4M status=progress
   ```

2. Boot from USB

3. Run installer:
   ```bash
   sudo menu
   ```

## Available Commands

| Command | Description |
|---------|-------------|
| `menu` | Main interactive installer |
| `help` | Show help and available commands |
| `manual-partition` | Manual partition format/mount script |
| `nmtui` | Connect to WiFi |
| `gparted` | GUI partition editor |

## Structure

```
hosts/leopardus/
└── configuration.nix    # ISO host configuration

profiles/role/
└── installer.nix        # Installer profile (packages, services)

scripts/installer/
├── menu.sh              # Main installer script
├── help.sh              # Help display
├── manual-partition.sh  # Manual partitioning
└── README.md            # Script documentation
```

## NixOS ISO Reference

When modifying the installer, refer to these NixOS source files:

### Core ISO Modules

- **[iso-image.nix]** - ISO image builder, all `isoImage.*` and `image.*` options
- **[installation-cd-base.nix]** - Base installer config (EFI/USB boot, base packages)
- **[installation-cd-minimal.nix]** - Minimal installer (imports base + minimal profile)

### NixOS Profiles

- **[profiles/base.nix]** - Base packages (parted, vim, networking tools, etc.)
- **[profiles/minimal.nix]** - Minimal system (disables docs, reduces packages)

### Key Options

```nix
# ISO filename (default: nixos-${edition}-${version}-${system}.iso)
image.baseName = "my-installer";    # Results in my-installer.iso
isoImage.edition = "custom";        # Included in default baseName

# Boot options
isoImage.makeEfiBootable = true;
isoImage.makeUsbBootable = true;

# Volume label (used for boot)
isoImage.volumeID = "NIXOS_INSTALL";

# Menu labels
isoImage.appendToMenuLabel = " Installer";  # Default
isoImage.prependToMenuLabel = "Install ";
```

### Links

[iso-image.nix]: https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/installer/cd-dvd/iso-image.nix
[installation-cd-base.nix]: https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/installer/cd-dvd/installation-cd-base.nix
[installation-cd-minimal.nix]: https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix
[profiles/base.nix]: https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/profiles/base.nix
[profiles/minimal.nix]: https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/profiles/minimal.nix