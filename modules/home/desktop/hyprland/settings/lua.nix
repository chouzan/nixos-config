{
  osConfig,
  config,
  lib,
  pkgs,
  ...
}:

# Reference: <https://github.com/hyprwm/Hyprland/blob/main/example/hyprland.lua>

let
  cfg = osConfig.modules.desktop.hyprland;

  hyprctl = "${pkgs.hyprland}/bin/hyprctl";
  jq = "${pkgs.jq}/bin/jq";

  hypr-toggle-focus-layer = pkgs.writeShellScript "hypr-toggle-focus-layer" ''
    if ${hyprctl} activewindow -j | ${jq} -e '.floating' > /dev/null; then
      ${hyprctl} dispatch 'hl.dsp.focus({ window = "tiled" })'
    else
      ${hyprctl} dispatch 'hl.dsp.focus({ window = "floating" })'
    fi
  '';

  # Config-derived values the lua files read via `require("vars")`.
  varsLua = ''
    return {
      menu          = "rofi -show drun",
      fileManager   = "dolphin",
      terminal      = "kitty",
      editor        = "zeditor",
      ai            = "claude-desktop",
      webBrowser    = "firefox",
      mediaPlayer   = "spotify",

      toggleFocus   = "${hypr-toggle-focus-layer}",

      clipMan        = "clipse",
      clipManEnabled = ${lib.boolToString config.services.clipse.enable},
    }
  '';
in
{
  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland.extraLuaFiles = {
      vars = {
        content = varsLua;
        autoLoad = false;
      };

      binds = ./lua/binds.lua;
      autostart = ./lua/autostart.lua;
    };
  };
}
