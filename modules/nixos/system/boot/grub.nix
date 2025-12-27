{ config, lib, ... }:

{
  boot = {
    loader = {
      timeout = 15;

      efi = {
        efiSysMountPoint = lib.mkIf (config.fileSystems ? "/boot/efi") "/boot/efi";
        canTouchEfiVariables = true;
      };

      grub = {
        enable = true;
        efiSupport = true;
        devices = [ "nodev" ];
        useOSProber = true;
        default = "saved";
        theme = ../../../../assets/grub-themes/nixos;
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
