{ ... }:

{
  imports = [
    ./..
    ./nix.nix
    ./boot.nix
    ./hardware.nix
    ./security.nix
    ./secret.nix
    ./system.nix
    ./shell.nix
    ./container.nix
    ./etc-hosts.nix
    ./packages.nix
    ./nix-ld.nix
    ./nerdfonts.nix
    ./hyprland.nix
    ./stylix.nix
  ];
}
