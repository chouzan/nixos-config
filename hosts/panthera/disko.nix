{ ... }:

{
  disko.devices = {
    disk = {
      main = {
        device = "/dev/disk/by-id/nvme-GIGABYTE_GP-ASM2NE6200TTTD_SN210308903973";
        type = "disk";

        content = {
          type = "gpt";

          partitions = {
            "01-uefi" = {
              label = "uefi";
              size = "512M";
              type = "EF00";

              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot/efi";
                extraArgs = [ "-n" "uefi" ];

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

            "02-boot" = {
              label = "boot";
              size = "2G";

              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/boot";
                extraArgs = [ "-L" "boot" ];

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

            "03-swap" = {
              label = "swap";
              size = "66G";

              content = {
                type = "swap";
                randomEncryption = false;
                extraArgs = [ "-L" "swap" ];
              };
            };

            "04-root" = {
              label = "root";
              size = "350G";

              content = {
                type = "btrfs";
                extraArgs = [ "-L" "root" ];

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

            "05-home" = {
              label = "home";
              size = "100%";

              content = {
                type = "btrfs";
                extraArgs = [ "-L" "home" ];

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
