{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config) modules;
  cfg = modules.hardware;
in
{
  config = lib.mkMerge [
    {
      # Hardware diagnostic utilities, sensors
      environment.systemPackages = lib.optionals modules.packages.admin.enable [ pkgs.lm_sensors ];
    }

    (lib.mkIf cfg.cpu.amd.enable {
      hardware.cpu.amd.updateMicrocode = config.hardware.enableRedistributableFirmware;

      boot = {
        # Alternative temperature monitoring module for Zen family AMD CPUs
        extraModulePackages = [ config.boot.kernelPackages.zenpower ];

        # Default AMD CPU temperature monitoring module
        blacklistedKernelModules = [ "k10temp" ];

        kernelModules = [
          # KVM virtualization support for AMD CPUs
          "kvm-amd"

          "zenpower"
        ];
      };
    })
  ];
}
