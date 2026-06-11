{ libs, ... }:

let
  inherit (libs) utils;
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
  };
}
