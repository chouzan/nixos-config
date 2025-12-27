# Troubleshooting

Common issues and their solutions for this NixOS configuration.

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
