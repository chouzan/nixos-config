{ config, lib, ... }:

let
  inherit (config) modules;
in
{
  boot = {
    kernelParams = [
      # Use S3 sleep (suspend-to-RAM)
      "mem_sleep_default=deep"

      # TODO: Evaluate lz4 compression (faster resume, requires kernel config: CONFIG_HIBERNATION_COMP_LZ4=y)
      # TODO: Evaluate zstd compression (better ratio, requires kernel config: CONFIG_HIBERNATION_COMP_ZSTD=y)
      "hibernate.compressor=lzo"
    ]
    # Use RTC wakeup timer for suspend/resume/hibernation (laptops)
    ++ lib.optional modules.hardware.battery.enable "rtc_cmos.use_acpi_alarm=1";

    # NOTE: Escape hatch - this module sets a nixpkgs option directly with mkDefault
    # so hosts can override with direct assignment. If more cases like this emerge,
    # consider introducing a mkOverridable helper or moving to a profile.
    resumeDevice = lib.mkDefault "/dev/disk/by-partlabel/swap";
  };

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
