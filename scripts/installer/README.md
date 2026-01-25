# NixOS Installer

## Structure

```
hosts/leopardus/
└── configuration.nix      # Installer ISO host config

scripts/installer/
├── menu.sh                # Main interactive installer
├── help.sh                # Help and command reference
├── manual-partition.sh    # Manual partition format/mount
└── welcome.sh             # TTY1 welcome message
```

## Build

```bash
nix build .#installer
```

The ISO will be at `result/iso/*.iso`.

## Usage

1. Write ISO to USB:
   ```bash
   sudo dd if=result/iso/*.iso of=/dev/sdX bs=4M status=progress
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
- **Scripts:** `scripts/installer/`
- **Docs:** `docs/PARTITIONING.md`
