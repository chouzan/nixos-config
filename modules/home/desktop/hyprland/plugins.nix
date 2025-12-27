{ osConfig, lib, ... }:

let
  cfg = osConfig.modules.desktop.hyprland;
in
{
  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland.settings.plugin = {
      hyprbars = {
        bar_height = 20;
        on_double_click = "hyprctl dispatch fullscreen 1";

        hyprbars-button = [
          "rgb(ff4040), 10, , hyprctl dispatch killactive"
          "rgb(eeee11), 10, , hyprctl dispatch fullscreen 1"
        ];
      };
    };
  };
}
