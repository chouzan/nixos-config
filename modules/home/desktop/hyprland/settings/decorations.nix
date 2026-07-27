{ osConfig, lib, ... }:

# Reference: <https://wiki.hypr.land/Configuring/Basics/Variables/#decoration>

let
  cfg = osConfig.modules.desktop.hyprland;
in
{
  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland.settings.config.decoration = {
      rounding = 10;
      rounding_power = 2;

      active_opacity = 1.0;
      inactive_opacity = 1.0;

      dim_inactive = true;
      dim_strength = 0.15;

      shadow = {
        enabled = true;
        range = 4;
        render_power = 3;
        # color = "#1a1a1aee";
      };

      blur = {
        enabled = true;
        size = 3;
        passes = 1;
        vibrancy = 0.1696;
      };
    };
  };
}
