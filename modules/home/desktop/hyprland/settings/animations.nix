{ osConfig, lib, ... }:

# Reference: <https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/>

let
  cfg = osConfig.modules.desktop.hyprland;

  # `hl.curve(name, { type = "bezier", points = { {x1,y1}, {x2,y2} } })`.
  mkBezier = name: p1x: p1y: p2x: p2y: {
    _args = [
      name
      {
        type = "bezier";
        points = [
          [
            p1x
            p1y
          ]
          [
            p2x
            p2y
          ]
        ];
      }
    ];
  };
in
{
  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland.settings = {
      config.animations.enabled = true;

      curve = [
        (mkBezier "easeOutQuint" 0.23 1.0 0.32 1.0)
        (mkBezier "easeInOutCubic" 0.65 0.05 0.36 1.0)
        (mkBezier "linear" 0.0 0.0 1.0 1.0)
        (mkBezier "almostLinear" 0.5 0.5 0.75 1.0)
        (mkBezier "quick" 0.15 0.0 0.1 1.0)
      ];

      # `hl.animation({ leaf, enabled, speed, bezier, style? })`.
      animation = [
        # -- Global ------------------------------------------------------------

        {
          leaf = "global";
          enabled = true;
          speed = 10;
          bezier = "default";
        }

        # -- Windows -----------------------------------------------------------

        {
          leaf = "windows";
          enabled = true;
          speed = 4.79;
          bezier = "easeOutQuint";
        }

        {
          leaf = "windowsIn";
          enabled = true;
          speed = 4.1;
          bezier = "easeOutQuint";
          style = "popin 87%";
        }

        {
          leaf = "windowsOut";
          enabled = true;
          speed = 1.49;
          bezier = "linear";
          style = "popin 87%";
        }

        # -- Layers ------------------------------------------------------------

        {
          leaf = "layers";
          enabled = true;
          speed = 3.81;
          bezier = "easeOutQuint";
        }

        {
          leaf = "layersIn";
          enabled = true;
          speed = 4;
          bezier = "easeOutQuint";
          style = "fade";
        }

        {
          leaf = "layersOut";
          enabled = true;
          speed = 1.5;
          bezier = "linear";
          style = "fade";
        }

        # -- Fade --------------------------------------------------------------

        {
          leaf = "fade";
          enabled = true;
          speed = 3.03;
          bezier = "quick";
        }

        {
          leaf = "fadeIn";
          enabled = true;
          speed = 1.73;
          bezier = "almostLinear";
        }

        {
          leaf = "fadeOut";
          enabled = true;
          speed = 1.46;
          bezier = "almostLinear";
        }

        {
          leaf = "fadeLayersIn";
          enabled = true;
          speed = 1.79;
          bezier = "almostLinear";
        }

        {
          leaf = "fadeLayersOut";
          enabled = true;
          speed = 1.39;
          bezier = "almostLinear";
        }

        # -- Border ------------------------------------------------------------

        {
          leaf = "border";
          enabled = true;
          speed = 5.39;
          bezier = "easeOutQuint";
        }

        # -- Workspaces --------------------------------------------------------

        {
          leaf = "workspaces";
          enabled = true;
          speed = 1.94;
          bezier = "almostLinear";
          style = "fade";
        }

        {
          leaf = "workspacesIn";
          enabled = true;
          speed = 1.21;
          bezier = "almostLinear";
          style = "fade";
        }

        {
          leaf = "workspacesOut";
          enabled = true;
          speed = 1.94;
          bezier = "almostLinear";
          style = "fade";
        }
      ];
    };
  };
}
