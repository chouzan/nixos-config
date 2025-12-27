{ config, lib, ... }:

let
  inherit (config) modules;
in
{
  boot.kernelParams = [
    # Use S3 sleep (suspend-to-RAM)
    "mem_sleep_default=deep"

    "hibernate.compressor=zstd"

    # TODO: Explore zstd compression level
    # "hibernate.compressor_level="

    # Use RTC wakeup timer for suspend/resume/hibernation (laptops)
  ]
  ++ lib.optional modules.hardware.battery.enable "rtc_cmos.use_acpi_alarm=1";

  systemd.sleep.extraConfig = ''
    AllowSuspend=yes
    AllowHibernation=yes
    AllowHybridSleep=no
    AllowSuspendThenHibernate=yes
    SuspendState=mem
    MemorySleepMode=deep
    HibernateDelaySec=36h
    HibernateOnACPower=yes
  '';
}
