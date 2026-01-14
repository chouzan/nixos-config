{ ... }:

{
  imports = [
    ./..
    ./hardware
    ./system
    ./desktop
    ./programs
    ./bundles
    ./packages.nix
    ./stylix
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
}
