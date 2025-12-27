{
  osConfig,
  config,
  lib,
  ...
}:

let
  cfg = osConfig.modules.desktop.hyprland;
in
{
  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland.settings.windowrule = [
      {
        name = "prevent-maximize";
        "match:class" = ".*";

        suppress_event = "maximize";
      }

      {
        name = "transient-prevent-focus";
        "match:class" = "^$";
        "match:title" = "^$";
        "match:xwayland" = true;
        "match:float" = true;
        "match:fullscreen" = false;
        "match:pin" = false;

        no_focus = "on";
      }

      # TODO: Guard with options (modules.bundles.screenshot)
      # Screenshot annotation tool
      {
        name = "satty";
        "match:class" = "satty";

        float = "on";
        size = "60% 60%";
        stay_focused = "on";
      }
    ]

    # Clipboard manager
    ++ lib.optional config.services.clipse.enable {
      name = "clipse";
      "match:class" = "clipse";

      float = "on";
      size = "622 652";
      stay_focused = "on";
    };
  };
}
