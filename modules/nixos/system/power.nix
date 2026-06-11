{
  config,
  lib,
  libs,
  ...
}:

let
  inherit (config) modules;
  inherit (libs) utils;
in
{
  config = lib.mkMerge [
    {
      services.logind.settings.Login.HandlePowerKey = "suspend";

      powerManagement = {
        enable = utils.mkModuleDefault true;

        # TODO: Explore split settings between desktop and laptop
        cpuFreqGovernor = "schedutil";
      };
    }

    (lib.mkIf modules.hardware.cpu.amd.enable {
      # AMD EPP (Energy Performance Preference) manager
      services.auto-epp = {
        enable = true;

        settings.Settings =
          if modules.hardware.battery.enable then
            {
              epp_state_for_AC = "balance_performance";
              epp_state_for_BAT = "balance_power";
            }
          else
            {
              epp_state_for_AC = "performance";
            };
      };
    })

    (lib.mkIf modules.hardware.battery.enable {
      powerManagement.powertop.enable = true;

      # TODO: Explore TLP for charging limit
    })
  ];
}
