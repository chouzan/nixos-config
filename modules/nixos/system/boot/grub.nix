{ ... }:

{
  boot.loader.grub = {
    enable = true;

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
  };
}
