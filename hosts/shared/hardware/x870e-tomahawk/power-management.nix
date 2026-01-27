{ pkgs, ... }:

{
  # Workaround: r8169 (Realtek ethernet) driver fails to resume from hibernate
  # The driver's transmit queue times out with NETDEV WATCHDOG errors and
  # internal reset fails (rtl_rxtx_empty_cond == 0)
  # Reloading the module after resume resets the driver state completely
  powerManagement.resumeCommands = ''
    ${pkgs.kmod}/bin/modprobe -r r8169
    ${pkgs.kmod}/bin/modprobe r8169
  '';
}
