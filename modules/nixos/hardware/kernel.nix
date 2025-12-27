{ config, lib, ... }:

let
  cfg = config.modules.hardware;
in
{
  boot.kernelParams = [
    # Microsoft ACPI Device Specific Method for better hardware compatibility
    "acpi.prefer_microsoft_dsm_guid=1"
  ]
  ++ lib.optional cfg.battery.enable "pcie_aspm.policy=powersave";
}
