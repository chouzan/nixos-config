{ ... }:

{
  imports = [
    ./kernel.nix
    ./cpu.nix
    ./gpu.nix
    ./graphic.nix
    ./video.nix
    ./audio.nix
    ./ssd.nix
  ];

  # Kernel modules to make available during early boot (initrd stage) to access storage devices
  boot.initrd.availableKernelModules = [
    # USB 3.0 host controller
    "xhci_pci"

    # USB 2.0 host controller
    "ehci_pci"

    # SATA host controller (AHCI mode)
    "ahci"

    # NVMe drives
    "nvme"

    # SCSI disk driver (SATA/USB drives)
    "sd_mod"

    # USB mass storage devices
    "usb_storage"

    # USB keyboards/mice (for LUKS password entry)
    "usbhid"
  ];

  hardware = {
    # Enable non-free firmware blobs for hardware devices
    enableRedistributableFirmware = true;

    bluetooth.enable = true;
  };
}
