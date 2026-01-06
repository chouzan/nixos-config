# NixOS Installer

> **Note:** The installer has been refactored into a proper host configuration.
> See the new locations below.

## New Structure

The installer is now organized as:

```
hosts/leopardus/
└── configuration.nix      # Installer ISO host config

profiles/role/
└── installer.nix          # Installer profile (packages, services)

scripts/installer/
├── menu.sh                # Main interactive installer
├── help.sh                # Help and command reference
└── manual-partition.sh    # Manual partition format/mount
```

## Build

```bash
nix build .#installer
```

The ISO will be at `result/iso/nixos-installer.iso`.

## Usage

See [hosts/leopardus/configuration.nix](../hosts/leopardus/configuration.nix) for full documentation.

1. Write ISO to USB:
   ```bash
   sudo dd if=result/iso/nixos-installer.iso of=/dev/sdX bs=4M status=progress
   ```

2. Boot from USB

3. (Optional) Connect to WiFi:
   ```bash
   nmtui
   ```

4. Run installer:
   ```bash
   sudo menu
   ```

## Related Files

- **Host config:** `hosts/leopardus/configuration.nix`
- **Profile:** `profiles/role/installer.nix`
- **Scripts:** `scripts/installer/`
- **Docs:** `docs/PARTITIONING.md`
