{ config, lib, ... }:

{
  boot = {
    supportedFilesystems = [
      "vfat"
      "btrfs"
      "ntfs"
    ];

    loader = {
      timeout = 15;
      efi.efiSysMountPoint = lib.mkIf (config.fileSystems ? "/boot/efi") "/boot/efi";

      grub = {
        enable = true;
        efiSupport = true;
        devices = [ "nodev" ];
        efiInstallAsRemovable = true;
        useOSProber = true;
        default = "saved";
        timeoutStyle = "menu";
        theme = ../../../../assets/grub-themes/nixos;
      };
    };
  };
}
