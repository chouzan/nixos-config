{ osConfig, lib, ... }:

# References:
# - <https://wiki.hypr.land/Configuring/Layouts/Master-Layout/>
# - <https://wiki.hypr.land/Configuring/Layouts/Dwindle-Layout/>

let
  cfg = osConfig.modules.desktop.hyprland;
in
{
  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland.settings.config = {
      general.layout = "master";

      master = {
        orientation = "center";
        slave_count_for_center_master = 3;
      };

      dwindle = {
        preserve_split = true;
      };
    };
  };
}
