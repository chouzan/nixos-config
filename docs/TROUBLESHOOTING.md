# Troubleshooting

Common issues and their solutions for this NixOS configuration.

## Hibernation Issues

### Swap Device Busy Error

**Symptom:**
```
swapon: /dev/sdX: swapon failed: Device or resource busy
```

**Cause:**
Failed hibernation resume can leave the swap device in a locked state. This happens when:
- Resume detected hibernation image but decompression failed
- Kernel couldn't load the required compression module
- System was powered off during hibernation

**Solution:**
```bash
# Immediate fix: Reboot the system
sudo reboot

# After reboot, verify swap is active
swapon --show
```

**Prevention:**
- Ensure correct hibernate compressor is configured (see below)
- Verify `boot.resumeDevice` is set correctly if multiple swaps exist

---

### Hibernation Compression Not Available

**Symptom:**
```
PM: Image signature found, resuming
PM: hibernation: lz4 compression is not available
```

or

```
Booting kernel: `zstd' invalid for parameter `hibernate.compressor'
```

**Cause:**
The kernel doesn't have the specified compressor compiled in. NixOS kernel by default only includes `lzo`:

| Compressor | Status | Performance |
|------------|--------|-------------|
| lzo | ✅ Built-in | Fast |
| lz4 | ❌ Not enabled | Faster |
| zstd | ❌ Not enabled | Best compression |

**Solution 1: Use LZO (Recommended)**

Check `modules/nixos/system/sleep.nix` - it should be set to:
```nix
boot.kernelParams = [
  "hibernate.compressor=lzo"
];
```

Rebuild and reboot:
```bash
sudo nixos-rebuild switch
sudo reboot
```

**Solution 2: Enable LZ4 or ZSTD (Requires Kernel Rebuild)**

Add to your host configuration:
```nix
boot.kernelPatches = [{
  name = "hibernate-lz4";
  patch = null;  # null = config only, no code changes
  extraStructuredConfig = with lib.kernel; {
    HIBERNATION_COMP_LZ4 = yes;
  };
}];
```

For zstd:
```nix
boot.kernelPatches = [{
  name = "hibernate-zstd";
  patch = null;
  extraStructuredConfig = with lib.kernel; {
    HIBERNATION_COMP_ZSTD = yes;
  };
}];
```

Then update the compressor in `modules/nixos/system/sleep.nix` and rebuild (takes ~30 minutes for kernel compilation).

---

### Multiple Swap Partitions

**Symptom:**
- System tries to resume from wrong swap partition
- Hibernation works but resume fails
- Multiple Linux installations interfere with each other

**Cause:**
When multiple swap partitions exist (e.g., dual/triple boot with different Linux installations), NixOS auto-detection may check the wrong partition.

**Solution:**

Set explicit `boot.resumeDevice` in your disko.nix or configuration.nix:

```nix
# In hosts/<hostname>/disko.nix
{
  disko.devices = {
    # ... partition config ...
  };
  
  # Explicitly set which swap to use for hibernation
  boot.resumeDevice = "/dev/disk/by-partlabel/your-swap-label";
  
  boot.tmp.useTmpfs = true;
}
```

This prevents NixOS from checking swap partitions on other drives.

**Verify configuration:**
```bash
# Check which swap is active
swapon --show

# Check resume device in kernel params
cat /proc/cmdline | grep resume

# Check all swap partitions visible to system
lsblk -o NAME,SIZE,TYPE,FSTYPE,LABEL,MOUNTPOINT | grep swap
```

---

### Swap Encryption Blocks Hibernation

**Symptom:**
- Hibernation completes but resume fails
- No resume image found on boot
- Swap type shows as encrypted

**Cause:**
Encrypted swap (`randomEncryption = true`) generates a new encryption key on each boot, making resume impossible.

**Solution:**

In your disko.nix swap configuration:
```nix
swap = {
  label = "swap";
  size = "18G";
  content = {
    type = "swap";
    priority = 32767;
    randomEncryption = false;  # REQUIRED for hibernation
  };
};
```

If you need both encryption and hibernation, use LUKS encryption at the partition level (not swap-level), but this requires additional configuration.

---

### Hibernation Checklist

Before reporting hibernation issues, verify:

1. **Swap size:** At least RAM + 2GB
   ```bash
   free -h  # Check RAM size
   swapon --show  # Check swap size
   ```

2. **Swap encryption disabled:**
   ```bash
   sudo blkid | grep swap
   # Should show TYPE="swap", not TYPE="crypto_LUKS"
   ```

3. **Resume device configured (if multiple swaps):**
   ```bash
   grep resumeDevice /etc/nixos/hosts/*/disko.nix
   # or check configuration.nix
   ```

4. **Correct compressor:**
   ```bash
   cat /proc/cmdline | grep hibernate.compressor
   # Should show: hibernate.compressor=lzo
   ```

5. **No wakeup sources:**
   ```bash
   grep enabled /proc/acpi/wakeup
   # See USB Wake-Up Issues section below
   ```

---

## USB Wake-Up Issues

If your system wakes unexpectedly from suspend due to USB devices (common on laptops), here are two approaches to fix it.

### Quick Fix: Disable USB Controller

This method disables the entire USB controller from waking the system.

**1. Identify wake-capable controllers:**
```bash
grep . /proc/acpi/wakeup
```

Look for entries with `*enabled` status, commonly `XHC1`, `XHC0`, or similar.

**2. Test the fix (temporary):**
```bash
echo XHC1 | sudo tee /proc/acpi/wakeup
```

Replace `XHC1` with your controller name. Test suspend/wake behavior.

**3. Make it permanent:**

Add a udev rule to your NixOS configuration:

```nix
services.udev.extraRules = ''
  ACTION=="add|change", SUBSYSTEM=="pci", DRIVER=="xhci_hcd", \
    ATTR{power/wakeup}="disabled"
'';
```

Then rebuild:
```bash
sudo nixos-rebuild switch
```

### Detailed Fix: Target Specific Device

This method is more precise, disabling only the problematic USB device while keeping others functional.

**1. Find the active host controller:**
```bash
cat /proc/acpi/wakeup
```

**2. Map controller to USB bus:**
```bash
lsusb -t
```

**3. Locate the culprit device:**
```bash
grep . /sys/bus/usb/devices/*/power/wakeup
```

Look for devices showing `enabled`.

**4. Get device vendor and product IDs:**
```bash
udevadm info -q all -p /sys/bus/usb/devices/<device-path> | grep -E 'ID_VENDOR_ID|ID_MODEL_ID'
```

Replace `<device-path>` with the path from step 3 (e.g., `1-3`).

**5. Add targeted udev rule:**

```nix
services.udev.extraRules = ''
  ACTION=="add|bind|change", SUBSYSTEM=="usb", \
    ATTRS{idVendor}=="XXXX", ATTRS{idProduct}=="YYYY", \
    ATTR{power/wakeup}="disabled", \
    ATTR{power/control}="auto", \
    ATTR{power/autosuspend_delay_ms}="5000"
'';
```

Replace `XXXX` and `YYYY` with your device's vendor and product IDs.

**6. Apply the configuration:**
```bash
sudo nixos-rebuild switch
sudo udevadm control --reload
sudo udevadm trigger --action=add --subsystem-match=usb
```

**7. Verify the fix:**
```bash
# Check if wakeup is disabled
cat /sys/bus/usb/devices/<device-path>/power/wakeup
# Should output: disabled
```

### Example: Real Configuration

For a working example implementation, see `hosts/<hostname>/udev.nix` in your host configuration directory.

Example udev rule implementation:
```nix
# hosts/<hostname>/udev.nix
{ ... }:

{
  services.udev.extraRules = ''
    # Disable USB wake for specific problematic device
    ACTION=="add|bind|change", SUBSYSTEM=="usb", \
      ATTRS{idVendor}=="XXXX", ATTRS{idProduct}=="YYYY", \
      ATTR{power/wakeup}="disabled", \
      ATTR{power/control}="auto", \
      ATTR{power/autosuspend_delay_ms}="5000"
  '';
}
```

Then import this module in your host configuration:
```nix
# hosts/<hostname>/configuration.nix
{
  imports = [
    ./udev.nix
  ];
}
```
