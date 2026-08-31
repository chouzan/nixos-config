{ config, libs, ... }:

let
  inherit (libs) utils;
  esp = config.boot.loader.efi.efiSysMountPoint;
in
{
  boot.loader.grub = {
    enable = utils.mkModuleDefault true;

    # UEFI
    efiSupport = true;
    efiInstallAsRemovable = true;
    devices = [ "nodev" ];

    # Menu
    useOSProber = true;
    configurationLimit = 10;
    default = "saved";
    timeoutStyle = "menu";

    # Appearance
    theme = ../../../../assets/grub-themes/nixos;

    # Extras
    memtest86.enable = true;

    # A firmware boot order lists a named loader, and treats the removable path
    # as a device rather than an entry, so an installation that writes only the
    # removable path cannot be ordered ahead of another system.
    #
    # The copy is made by every run of the installer, right after it writes the
    # file it copies, so the two cannot drift. A copy written once and left
    # alone is the failure this avoids: firmware loads a loader from one
    # installation while it reads modules from another, and stops before any
    # menu appears.
    extraInstallCommands = ''
      install -Dm644 ${esp}/EFI/BOOT/BOOTX64.EFI ${esp}/EFI/NixOS/grubx64.efi
    '';
  };
}
