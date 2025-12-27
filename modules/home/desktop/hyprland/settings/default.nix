{
  osConfig,
  lib,
  libs,
  ...
}:

let
  inherit (osConfig) modules;
  inherit (libs) hyprland utils;

  cfg = modules.desktop.hyprland;

  hypUtils = hyprland.utils;

  extraWorkspace = [
    "special:terminal, on-created-empty:kitty"
  ];

  enabledMonitors = utils.getEnabledMonitors modules.monitors;
  monitors = lib.map hypUtils.toHyprlandMonitor enabledMonitors;
  monitorWorkspaces = hypUtils.getWorkspaceAssignments enabledMonitors;
  workspaces = monitorWorkspaces ++ extraWorkspace;
in
{
  imports = [
    ./layouts.nix
    ./binds.nix
    ./window-rules.nix
    ./decorations.nix
    ./animations.nix
  ];

  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland.settings = {
      monitor = utils.orIfEmpty [ ", preferred, auto, auto" ] monitors;
      workspace = utils.orIfEmpty [ ] workspaces;

      "$menu" = "rofi -show drun";
      "$fileManager" = "dolphin";
      "$terminal" = "kitty";
      "$editor" = "zeditor";
      "$ai" = "claude-desktop";
      "$webBrowser" = "firefox";
      "$musicPlayer" = "spotify";

      env = [
        "XCURSOR_SIZE,24"
        "HYPRCURSOR_SIZE,24"
      ];

      exec-once = [
        "nm-applet &"
        "waybar &"
        "hyprpaper &"
        "$editor"
        "$terminal"
        "$ai"
        "$webBrowser"
        "$musicPlayer"
      ];

      general = {
        # TODO: Cleanup
        # "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
        # "col.inactive_border" = "rgba(595959aa)";
        resize_on_border = true;
      };

      input = {
        numlock_by_default = true;
        touchpad.natural_scroll = true;
      };

      misc = {
        animate_manual_resizes = true;
        animate_mouse_windowdragging = true;
        enable_swallow = true;
        swallow_regex = "kitty";
        focus_on_activate = true;
      };
    };
  };
}
