{ ... }:

{
  boot = {
    loader = {
      timeout = 15;
      efi.canTouchEfiVariables = true;

      grub = {
        enable = true;
        efiSupport = true;
        devices = [ "nodev" ];
        useOSProber = true;
        default = "saved";
        theme = ../../grub/themes/nixos;
        timeoutStyle = "menu";
      };
    };

    supportedFilesystems = [
      "btrfs"
      "vfat"
      "ntfs"
    ];
  };
}
