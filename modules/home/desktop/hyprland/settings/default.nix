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
  inherit (hypUtils) mkEnv mkMonitor;

  # A `special:system` scratchpad that spawns a terminal on first use.
  extraWorkspaceRules = [
    {
      workspace = "special:system";
      on_created_empty = "kitty";
    }
  ];

  enabledMonitors = utils.getEnabledMonitors modules.monitors;
  monitors = lib.map hypUtils.toHyprlandMonitor enabledMonitors;
  monitorWorkspaceRules = hypUtils.getWorkspaceAssignments enabledMonitors;
  workspaceRules = monitorWorkspaceRules ++ extraWorkspaceRules;
in
{
  imports = [
    ./layouts.nix
    ./lua.nix
    ./local-settings.nix
    ./window-rules.nix
    ./decorations.nix
    ./animations.nix
  ];

  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland.settings = {
      monitor = utils.orIfEmpty [
        (mkMonitor {
          output = "";
          mode = "preferred";
          position = "auto";
          scale = "auto";
        })
      ] monitors;

      workspace_rule = workspaceRules;

      env = [
        (mkEnv "HYPRCURSOR_THEME" "Nordzy-hyprcursors")
        (mkEnv "HYPRCURSOR_SIZE" "24")
        (mkEnv "XCURSOR_THEME" "Nordzy-cursors")
        (mkEnv "XCURSOR_SIZE" "24")
      ];

      config = {
        xwayland.force_zero_scaling = true;

        general = {
          # TODO: Cleanup
          # col.active_border = { colors = [ "#33ccffee" "#00ff99ee" ]; angle = 45; };
          # col.inactive_border = "#595959aa";
          resize_on_border = true;
        };

        input = {
          numlock_by_default = true;
          touchpad.natural_scroll = true;
        };

        misc = {
          enable_swallow = true;
          swallow_regex = "kitty";
          focus_on_activate = true;
          middle_click_paste = false;
        };
      };
    };
  };
}
