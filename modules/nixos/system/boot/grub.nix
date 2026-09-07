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

    # The loader goes to the fallback path, \EFI\BOOT\BOOTX64.EFI, which any
    # installer may overwrite, and firmware names the entry it creates there
    # itself.
    #
    # A copy under \EFI\NixOS is written by this system alone, and an entry
    # pointing at it takes the name its creator chooses.
    #
    # The copy does nothing until `nixosadm boot create` writes that entry.
    #
    # Every rebuild remakes the copy, so it cannot go stale. A stale copy means
    # firmware loads one installation's loader while that loader reads another's
    # modules, and stops before any menu.
    extraInstallCommands = ''
      install -D ${esp}/EFI/BOOT/BOOTX64.EFI ${esp}/EFI/NixOS/grubx64.efi
    '';
  };
}
