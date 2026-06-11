{ libs, ... }:

let
  inherit (libs) utils;
in
{
  imports = [
    ./boot
    ./btrfs.nix
    ./user.nix
    ./networking.nix
    ./security.nix
    ./secrets.nix
    ./power.nix
    ./sleep.nix
    ./fonts.nix
    ./hosts.nix
  ];

  # Disable watchdog auto-reboot (prefer debugging hangs)
  systemd.settings.Manager.RebootWatchdogSec = "0";

  services = {
    # Firmware updates for hardware devices
    fwupd.enable = utils.mkModuleDefault true;

    # System clock synchronization via NTP (systemd daemon)
    timesyncd.enable = utils.mkModuleDefault true;
  };
}
