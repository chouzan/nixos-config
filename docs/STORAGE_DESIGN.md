# Storage Design

Storage architecture and filesystem configuration reference.

---

## Partition Layout

### Physical Partitions

```
Linux Partition Scheme:
├── EFI  (512MB-1GB, vfat)    [EFI bootloaders]
├── Boot (1-2GB, ext4)        [Kernels, initrd]
├── Swap (RAM + 2GB)          [Swap + hibernation]
├── Root (btrfs)              [System, /nix/store]
└── Home (btrfs)              [User data]
```

### Btrfs Subvolumes

**Root partition:**
```
@ → /
```

**Home partition:**
```
@home → /home
```

---

## Mount Configuration

### EFI (/boot/efi)
```nix
device = "/dev/disk/by-partlabel/uefi";
fsType = "vfat";
options = [ "defaults" "fmask=0077" "dmask=0077" "nodev" "nosuid" "noexec" ];
```

### Boot (/boot)
```nix
device = "/dev/disk/by-partlabel/boot";
fsType = "ext4";
options = [ "defaults" "noatime" "errors=remount-ro" "nodev" "nosuid" "noexec" ];
```

### Root (/)
```nix
device = "/dev/disk/by-partlabel/root";
fsType = "btrfs";
options = [ "subvol=@" "noatime" "compress=zstd:3" "space_cache=v2" "discard=async" ];
```

### Home (/home)
```nix
device = "/dev/disk/by-partlabel/home";
fsType = "btrfs";
options = [ "subvol=@home" "noatime" "compress=zstd:3" "space_cache=v2" "discard=async" ];
```

### Swap
```nix
swapDevices = [{
  device = "/dev/disk/by-partlabel/swap";
}];
```

**Important for hibernation:**
- Set `randomEncryption = false` in disko.nix (hibernation incompatible with swap encryption)
- Size must be at least RAM + 2GB for reliable hibernation
- Set `boot.resumeDevice` explicitly to specify which swap partition to use for hibernation
- This is especially important when multiple swap partitions exist on different drives

### Tmpfs (/tmp)
```nix
boot.tmp.useTmpfs = true;
boot.tmp.tmpfsSize = "50%";  # Adjust based on RAM
```

---

## Mount Options

| Option | Purpose |
|--------|---------|
| `noatime` | Disable access time updates (performance) |
| `compress=zstd:3` | Transparent compression, level 3 balanced |
| `space_cache=v2` | Improved free space tracking |
| `discard=async` | Async TRIM for SSDs |
| `errors=remount-ro` | Remount read-only on errors (ext4) |
| `fmask=0077, dmask=0077` | Restrict permissions (vfat) |
| `nodev, nosuid, noexec` | Security restrictions for boot partitions |

---

## Hibernation Configuration

### Requirements

**Swap Partition:**
```nix
# In disko.nix
swap = {
  label = "swap";
  size = "18G";  # RAM + 2GB minimum
  content = {
    type = "swap";
    randomEncryption = false;  # REQUIRED for hibernation
  };
};
```

**Resume Device (if multiple swaps on different drives):**
```nix
# In disko.nix or configuration.nix
boot.resumeDevice = "/dev/disk/by-partlabel/swap";
```

**Why set resumeDevice explicitly:**
- NixOS will check all swap partitions for hibernation images by default
- This can cause issues with multiple Linux installations on different drives
- Explicit configuration ensures consistent, predictable behavior
- Prevents the system from attempting to resume from the wrong swap partition

### Compression

Hibernation uses kernel-level compression. The default NixOS kernel only includes `lzo`:

| Compressor | Speed | Ratio | Kernel Config Required |
|------------|-------|-------|------------------------|
| lzo | Fast | Good | ✅ Built-in (default) |
| lz4 | Faster | Good | `CONFIG_HIBERNATION_COMP_LZ4=y` |
| zstd | Slower | Better | `CONFIG_HIBERNATION_COMP_ZSTD=y` |

The system configures `lzo` by default in `modules/nixos/system/sleep.nix`. To use lz4 or zstd, you must rebuild the kernel with the appropriate configuration option enabled.

### Common Issues

**"Device or resource busy" on swap:**
- Usually caused by failed hibernation resume leaving device locked
- Solution: Reboot to clear the lock

**"lz4/zstd compression is not available":**
- Kernel doesn't have the compressor compiled in
- Solution: Use lzo (default) or add kernel patch for lz4/zstd

**Immediate wake after hibernate:**
- Check wakeup sources in `/proc/acpi/wakeup`
- See `docs/TROUBLESHOOTING.md` for USB wake issues

## Design Rationale

### Separate /boot/efi and /boot

**Benefits:**
- EFI (vfat) isolated from kernels (ext4)
- ext4 more reliable for kernel storage
- Smaller EFI partition requirement

### Minimal Subvolumes

Only separate what requires different treatment:
- `@` for root system
- `@home` for user data isolation

No separate subvolumes for `/nix`, `/var/cache`, `/var/log`, or `/var/lib/containers`.

### NOCOW for Containers (Optional)

For heavy container usage, disable COW on container storage:

```nix
systemd.tmpfiles.rules = [
  "h /var/lib/containers - - - - +C"
];
```

Apply only if experiencing container performance issues.

---

## Sizing Guidelines

| Partition | Size Formula | Example (16GB RAM) | Example (64GB RAM) |
|-----------|--------------|--------------------|--------------------|
| EFI | 512MB-1GB | 1GB | 1GB |
| Boot | 1-2GB | 2GB | 2GB |
| Swap | RAM + 2GB | 18GB | 66GB |
| Root | 100-300GB | 100-200GB | 200-300GB |
| Home | Remaining | Remaining | Remaining |

**Swap sizing:** Match RAM size + 2GB margin for hibernation support. Set `randomEncryption = false` in disko.nix to enable hibernation (encrypted swap prevents resume).

**Root sizing:** Depends on disk size:
- 512GB disk: 100-150GB root
- 1TB disk: 150-200GB root
- 2TB disk: 200-300GB root

---

## Host Configurations

### Example Laptop Configuration

**Configurations:**
- `hosts/<hostname>/storage.nix` - Legacy mount configuration (some hosts)
- `hosts/<hostname>/disko.nix` - Modern automated configuration (preferred)

### Example Desktop Configuration

**Configuration:** `hosts/<hostname>/disko.nix`
- 2TB disk
- 66GB swap (64GB RAM)
- 300GB root
- Automated via disko

---

## Filesystem Choice

**Btrfs selected for:**
- Transparent compression (20-30% space savings)
- Subvolume flexibility
- Data checksumming

**Not used for:**
- System snapshots (NixOS generations handle this)
- RAID configurations
- Deduplication
