{
  config,
  lib,
  libs,
  ...
}:

let
  inherit (libs) utils;
in
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

    # Quiet boot

    consoleLogLevel = 3;
    initrd.verbose = false;

    kernelParams = [
      "quiet"
      "splash"
      "loglevel=3"
      "rd.systemd.show_status=auto"
      "rd.udev.log_level=3"
      "systemd.show_status=auto"
      "udev.log_level=3"
      "vt.global_cursor_default=0"
    ];

    # Splash screen

    plymouth.enable = utils.mkModuleDefault true;
  };
}
