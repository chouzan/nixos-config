# Leopardus - NixOS Installer ISO
#
# A bootable installer that supports multiple hosts and installation methods.
#
# Build:
#   nix build .#installer -o out
#
# The ISO will be at out/iso/<filename>.iso
#
# ISO Filename:
#   Default: nixos-${edition}-${version}-${system}.iso
#   Example: nixos-minimal-26.05.20251230.cad22e7-x86_64-linux.iso
#
#   To customize, override these options:
#     image.baseName = "my-installer";  # Results in my-installer.iso
#     isoImage.edition = "custom";      # Included in default baseName
#
# Usage:
#   1. Write ISO: sudo dd if=out/iso/*.iso of=/dev/sdX bs=4M status=progress
#   2. Boot from USB
#   3. Run: sudo menu

{
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  imports = [
    # NixOS installer base (includes iso-image.nix, profiles/base.nix, etc.)
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"

    # Installer profile
    ../../profiles/role/installer.nix
  ];

  # ISO boot configuration
  isoImage = {
    makeEfiBootable = lib.mkDefault true;
    makeUsbBootable = lib.mkDefault true;
  };

  # Embed the nixos-config in the ISO at /etc/nixos-config
  environment.etc."nixos-config".source = ../..;

  # Install scripts from scripts/installer/
  environment.systemPackages = [
    (pkgs.writeScriptBin "menu" (builtins.readFile ../../scripts/installer/menu.sh))
    (pkgs.writeScriptBin "help" (builtins.readFile ../../scripts/installer/help.sh))
    (pkgs.writeScriptBin "manual-partition" (
      builtins.readFile ../../scripts/installer/manual-partition.sh
    ))
  ];
}
