# Installer profile
#
# Common configuration for NixOS installer environments.
# Used by the leopardus (installer ISO) host.
#
# Note: This profile is used with installation-cd-minimal.nix which already
# includes NixOS profiles/base.nix (parted, vim, networking tools, etc.)

{ lib, pkgs, ... }:

{
  # Additional packages for installation
  # (NixOS profiles/base.nix already includes parted, vim, zip, jq, etc.)
  environment.systemPackages = with pkgs; [
    # GUI partitioning (base only has CLI tools)
    gparted
    gnome-disk-utility

    # Additional utilities
    ripgrep
    fd
    htop
  ];

  # Network configuration
  networking.networkmanager.enable = lib.mkDefault true;
  networking.wireless.enable = lib.mkForce false;

  # Time configuration
  time = {
    timeZone = lib.mkDefault "Asia/Jakarta";
    hardwareClockInLocalTime = lib.mkDefault true; # Windows dual-boot compatibility
  };

  # SSH for remote installation
  services.openssh = {
    enable = lib.mkDefault true;
    settings.PermitRootLogin = lib.mkDefault "yes";
  };

  # Auto-login for convenience
  services.getty.autologinUser = lib.mkDefault "root";

  # Enable flakes
  nix.settings.experimental-features = lib.mkDefault [
    "nix-command"
    "flakes"
  ];

  # Larger console font for readability
  console = {
    font = lib.mkDefault "ter-v22n";
    packages = [ pkgs.terminus_font ];
  };

  # Shell aliases
  environment.shellAliases = {
    install = "sudo menu";
    disks = "lsblk -f";
  };

  # Welcome message on TTY1
  programs.bash.interactiveShellInit = ''
    if [ "$(tty)" = "/dev/tty1" ]; then
      clear
      help
      echo ""
      echo "Quick start: sudo menu"
      echo ""
    fi
  '';
}
