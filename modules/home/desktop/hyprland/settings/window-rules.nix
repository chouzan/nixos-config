{
  osConfig,
  config,
  lib,
  libs,
  ...
}:

# Reference: <https://wiki.hypr.land/Configuring/Basics/Window-Rules/>

let
  inherit (libs) utils;
  cfg = osConfig.modules.desktop.hyprland;

  defaultWindowRules = [
    {
      name = "prevent-maximize";
      match.class = ".*";
      suppress_event = "maximize";
    }

    {
      name = "transient-prevent-focus";

      match = {
        class = "^$";
        title = "^$";
        xwayland = true;
        float = true;
        fullscreen = false;
        pin = false;
      };

      no_focus = true;
    }

    # TODO: Guard with options (modules.bundles.screenshot)
    # Screenshot annotation tool
    {
      name = "satty";
      match.class = "satty";
      float = true;
      size = "60% 60%";
      stay_focused = true;
    }
  ]

  # Clipboard manager
  ++ lib.optional config.services.clipse.enable {
    name = "clipse";
    match.class = "clipse";
    float = true;
    size = "622 652";
    stay_focused = true;
  };

  windowRules = if cfg.windowRules == [ ] then defaultWindowRules else cfg.windowRules;
in
{
  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland.settings.window_rule = utils.mkModuleDefault (
      windowRules ++ cfg.extraWindowRules
    );
  };
}
