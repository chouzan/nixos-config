# WARNING: Disko will DESTROY ALL DATA on the target disk!
_:

{
  disko.devices = {
    disk = {
      main = {
        device = "/dev/disk/by-id/ata-CT1000MX500SSD1_2132E5BE4F93";
        type = "disk";

        content = {
          type = "gpt";

          partitions = {
            uefi = {
              label = "lab-uefi";
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
              label = "lab-boot";
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
              label = "lab-swap";
              size = "34G";

              content = {
                type = "swap";
                randomEncryption = false;
              };
            };

            root = {
              label = "lab-root";
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
              label = "lab-home";
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

  boot = {
    resumeDevice = "/dev/disk/by-partlabel/lab-swap";
    tmp.useTmpfs = true;
  };
}
