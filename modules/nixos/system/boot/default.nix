{ pkgs, ... }:

{
  imports = [
    ./grub.nix
  ];

  # Use the latest kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;
}
