{ libs, ... }:

let
  inherit (libs) utils;
in
{
  # Disable watchdog auto-reboot (prefer debugging hangs)
  systemd.settings.Manager.RebootWatchdogSec = "0";

  services = {
    # Firmware updates for hardware devices
    fwupd.enable = utils.mkModuleDefault true;

    # System clock synchronization via NTP (systemd daemon)
    timesyncd.enable = utils.mkModuleDefault true;
  };
}
