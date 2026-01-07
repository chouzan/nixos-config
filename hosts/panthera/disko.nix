# WARNING: Disko will DESTROY ALL DATA on the target disk!
_:

{
  disko.devices = {
    disk = {
      main = {
        device = "/dev/disk/by-id/CHANGE-ME";
        type = "disk";

        content = {
          type = "gpt";

          partitions = {
            uefi = {
              label = "uefi";
              size = "512M";
              type = "EF00";

              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot/efi";

                mountOptions = [
                  "defaults"
                  "fmask=0077"
                  "dmask=0077"
                  "noatime"
                  "nodev"
                  "nosuid"
                  "noexec"
                ];
              };
            };

            boot = {
              label = "boot";
              size = "2G";

              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/boot";

                mountOptions = [
                  "defaults"
                  "noatime"
                  "errors=remount-ro"
                  "nodev"
                  "nosuid"
                  "noexec"
                ];
              };
            };

            swap = {
              label = "swap";
              size = "34G";

              content = {
                type = "swap";
                randomEncryption = false;
              };
            };

            root = {
              label = "root";
              size = "350G";

              content = {
                type = "btrfs";

                subvolumes = {
                  "@" = {
                    mountpoint = "/";

                    mountOptions = [
                      "defaults"
                      "noatime"
                      "compress=zstd:3"
                      "discard=async"
                      "space_cache=v2"
                    ];
                  };
                };
              };
            };

            home = {
              label = "home";
              size = "100%";

              content = {
                type = "btrfs";
                subvolumes = {
                  "@home" = {
                    mountpoint = "/home";

                    mountOptions = [
                      "defaults"
                      "noatime"
                      "compress=zstd:3"
                      "discard=async"
                      "space_cache=v2"
                    ];
                  };
                };
              };
            };
          };
        };
      };
    };
  };

  boot.tmp.useTmpfs = true;
}
