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
  priority = 32767;
}];
```

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

**Swap sizing:** Match RAM size + 2GB margin for hibernation support.

**Root sizing:** Depends on disk size:
- 512GB disk: 100-150GB root
- 1TB disk: 150-200GB root
- 2TB disk: 200-300GB root

---

## Host Configurations

### Example Laptop Configuration

**Current:** `hosts/<hostname>/storage.nix`
- Single vfat /boot
- Basic mount options

**Target:** `hosts/<hostname>/storage-future.nix`
- Separate EFI + boot
- Improved mount options
- @home subvolume

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
