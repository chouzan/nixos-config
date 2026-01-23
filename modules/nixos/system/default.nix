{ ... }:

{
  imports = [
    ./boot
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
    fwupd.enable = true;

    # System clock synchronization via NTP (systemd daemon)
    timesyncd.enable = true;
  };
}
