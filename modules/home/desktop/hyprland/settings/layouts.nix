{ osConfig, lib, ... }:

let
  cfg = osConfig.modules.desktop.hyprland;
in
{
  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland.settings = {
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
