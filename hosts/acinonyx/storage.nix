_:

{
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-partlabel/root";
      fsType = "btrfs";

      options = [
        "subvol=@"
        "defaults"
        "noatime"
        "compress=zstd"
      ];
    };

    "/boot" = {
      device = "/dev/disk/by-partlabel/boot";
      fsType = "vfat";

      options = [
        "fmask=0077"
        "dmask=0077"
      ];
    };

    "/home" = {
      device = "/dev/disk/by-partlabel/home";
      fsType = "btrfs";

      options = [
        "defaults"
        "noatime"
        "compress=zstd"
      ];
    };
  };

  swapDevices = [
    {
      device = "/dev/disk/by-partlabel/swap";

      # Highest swap priority
      priority = 32767;
    }
  ];

  boot.tmp.useTmpfs = true;
}
