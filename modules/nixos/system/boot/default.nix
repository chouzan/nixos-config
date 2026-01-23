{ config, lib, ... }:

{
  imports = [
    ./grub.nix
  ];

  boot = {
    supportedFilesystems = [
      "vfat"
      "btrfs"
      "ntfs"
    ];

    initrd.systemd.enable = true;

    loader = {
      timeout = 15;
      efi.efiSysMountPoint = lib.mkIf (config.fileSystems ? "/boot/efi") "/boot/efi";
    };
  };
}
