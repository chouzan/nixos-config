{
  osConfig,
  lib,
  libs,
  ...
}:

let
  cfg = osConfig.modules.desktop.hyprland;
  inherit (libs) hyprland utils;

  hypUtils = hyprland.utils;
  enabledMonitors = utils.getEnabledMonitors osConfig.modules.monitors;

  # TODO: WORKAROUND:BEGIN aquamarine#240 — remove when PR#312 lands
  reModeset = lib.concatStringsSep " && " (
    lib.map (
      m:
      "hyprctl keyword monitor ${m.name},preferred,auto,${toString m.scale}"
      + " && hyprctl keyword monitor ${hypUtils.toHyprlandMonitor m}"
    ) enabledMonitors
  );
  # TODO: WORKAROUND:END aquamarine#240
in
{
  config = lib.mkIf cfg.enable {
    services.hypridle = {
      enable = true;

      settings = {
        general = {
          lock_cmd = "pidof hyprlock || hyprlock"; # avoid starting multiple hyprlock instances.
          before_sleep_cmd = "loginctl lock-session"; # lock before suspend.
          # TODO: WORKAROUND:aquamarine#240 — revert to just "hyprctl dispatch dpms on"
          after_sleep_cmd = "hyprctl dispatch dpms on && sleep 2 && ${reModeset}";
        };

        listener = [
          {
            timeout = 150; # 2.5min.
            on-timeout = "brightnessctl -s set 10"; # set monitor backlight to minimum, avoid 0 on OLED monitor.
            on-resume = "brightnessctl -r"; # monitor backlight restore.
          }

          # turn off keyboard backlight, comment out this section if you dont have a keyboard backlight.
          {
            timeout = 150; # 2.5min.
            on-timeout = "brightnessctl -sd rgb:kbd_backlight set 0"; # turn off keyboard backlight.
            on-resume = "brightnessctl -rd rgb:kbd_backlight"; # turn on keyboard backlight.
          }

          {
            timeout = 300; # 5min
            on-timeout = "loginctl lock-session"; # lock screen when timeout has passed
          }

          {
            timeout = 330; # 5.5min
            on-timeout = "hyprctl dispatch dpms off"; # screen off when timeout has passed
            # TODO: WORKAROUND:aquamarine#240 — revert to just "hyprctl dispatch dpms on && brightnessctl -r"
            on-resume = "hyprctl dispatch dpms on && brightnessctl -r && sleep 2 && ${reModeset}";
          }

          {
            timeout = 1800; # 30min
            on-timeout = "systemctl suspend"; # suspend pc
          }
        ];
      };
    };
  };
}
