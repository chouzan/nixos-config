{ osConfig, lib, ... }:

let
  cfg = osConfig.modules.desktop.hyprland;
in
{
  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland.settings.animations = {
      enabled = true;

      bezier = [
        "easeOutQuint, 0.23, 1.0, 0.32, 1.0"
        "easeInOutCubic, 0.65, 0.05, 0.36, 1.0"
        "linear, 0, 0, 1.0, 1.0"
        "almostLinear, 0.5, 0.5, 0.75, 1.0"
        "quick, 0.15, 0, 0.1, 1.0"
      ];

      animation = [
        "global, 1, 10, default"

        "windows, 1, 4.79, easeOutQuint"
        "windowsIn, 1, 4.1, easeOutQuint, popin 87%"
        "windowsOut, 1, 1.49, linear, popin 87%"

        "layers, 1, 3.81, easeOutQuint"
        "layersIn, 1, 4, easeOutQuint, fade"
        "layersOut, 1, 1.5, linear, fade"

        "fade, 1, 3.03, quick"
        "fadeIn, 1, 1.73, almostLinear"
        "fadeOut, 1, 1.46, almostLinear"
        "fadeLayersIn, 1, 1.79, almostLinear"
        "fadeLayersOut, 1, 1.39, almostLinear"

        "border, 1, 5.39, easeOutQuint"

        "workspaces, 1, 1.94, almostLinear, fade"
        "workspacesIn, 1, 1.21, almostLinear, fade"
        "workspacesOut, 1, 1.94, almostLinear, fade"
      ];
    };
  };
}
