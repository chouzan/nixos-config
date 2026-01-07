_:

{
  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-partlabel/boot";
      fsType = "ext4";

      options = [
        "defaults"
        "noatime"
        "errors=remount-ro"
        "nodev"
        "nosuid"
        "noexec"
      ];
    };

    "/boot/efi" = {
      device = "/dev/disk/by-partlabel/uefi";
      fsType = "vfat";

      options = [
        "defaults"
        "fmask=0077"
        "dmask=0077"
        "noatime"
        "nodev"
        "nosuid"
        "noexec"
      ];
    };

    "/" = {
      device = "/dev/disk/by-partlabel/root";
      fsType = "btrfs";

      options = [
        "subvol=@"
        "defaults"
        "noatime"
        "compress=zstd:3"
        "discard=async"
        "space_cache=v2"
      ];
    };

    "/home" = {
      device = "/dev/disk/by-partlabel/home";
      fsType = "btrfs";

      options = [
        "subvol=@home"
        "defaults"
        "noatime"
        "compress=zstd:3"
        "discard=async"
        "space_cache=v2"
      ];
    };
  };

  swapDevices = [ { device = "/dev/disk/by-partlabel/swap"; } ];

  boot.tmp.useTmpfs = true;
}
