{
  osConfig,
  lib,
  libs,
  ...
}:

let
  inherit (libs.hyprland.utils) hlDispatch;

  cfg = osConfig.modules.desktop.hyprland;

  closeWindow = hlDispatch "hl.dsp.window.close()";
  toggleMaximize = hlDispatch "hl.dsp.window.fullscreen({ mode = 'maximized', action = 'toggle' })";
in
{
  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      settings.config.plugin.hyprbars = {
        bar_height = 20;
        on_double_click = toggleMaximize;
      };

      # hyprbars registers bar buttons via its own `add_button` Lua function.
      # Fields: bg_color, fg_color, size, icon, action.
      extraConfig = ''
        hl.plugin.hyprbars.add_button({ bg_color = "rgb(ff4040)", fg_color = "rgb(ffffff)", size = 10, icon = "", action = ${builtins.toJSON closeWindow} })
        hl.plugin.hyprbars.add_button({ bg_color = "rgb(eeee11)", fg_color = "rgb(000000)", size = 10, icon = "", action = ${builtins.toJSON toggleMaximize} })
      '';
    };
  };
}
