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

    loader = {
      timeout = 15;
      efi.efiSysMountPoint = lib.mkIf (config.fileSystems ? "/boot/efi") "/boot/efi";
    };
  };
}
