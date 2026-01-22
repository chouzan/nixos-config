{ ... }:

{
  boot.loader.grub.extraEntries = ''
    menuentry "NixOS (neofelis)" {
      insmod part_gpt
      insmod fat
      insmod chain
      insmod search_label
      search --no-floppy --label=lab-uefi --set=esp
      chainloader ($esp)/EFI/BOOT/BOOTX64.EFI
      boot
    }
  '';
}
