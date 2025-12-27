# Monitor-to-Hyprland Bridge Module
# Processes modules.monitors options and makes them available to home-manager
{ config, lib, ... }:

let
  inherit (lib)
    concatStringsSep
    filter
    map
    mkIf
    optional
    ;
  cfg = config.modules;

  # Transform a single monitor config to Hyprland monitor string
  monitorToHyprlandString =
    monitor:
    let
      # Position
      inherit (monitor) position;

      # Base monitor specification
      baseSpec = if builtins.isString monitor.name then monitor.name else "desc:${monitor.name.desc}";

      # Resolution and refresh rate
      resolution = "${toString monitor.width}x${toString monitor.height}@${toString monitor.refreshRate}";

      # Scale (convert number to string if needed)
      scale = toString monitor.scale;

      # Hyprland-specific options
      hyprlandOpts = monitor.hyprland or { };

      # Build optional parameters
      optionalParams =
        optional (hyprlandOpts.vrr or 0 != 0) "vrr,${toString hyprlandOpts.vrr}"
        ++ optional (hyprlandOpts.transform or 0 != 0) "transform,${toString hyprlandOpts.transform}"
        ++ optional (hyprlandOpts.bitdepth or null != null) "bitdepth,${toString hyprlandOpts.bitdepth}"
        ++ optional (hyprlandOpts.adaptiveSync or false) "adaptivesync"
        ++ optional (hyprlandOpts.mirror or null != null) "mirror,${hyprlandOpts.mirror}";

      # Join optional parameters
      optionalStr = if optionalParams == [ ] then "" else ", ${concatStringsSep ", " optionalParams}";

    in
    "${baseSpec}, ${resolution}, ${position}, ${scale}${optionalStr}";

  # Transform enabled monitors to Hyprland strings
  hyprlandMonitors = map monitorToHyprlandString (filter (m: m.enabled) cfg.monitors);

  # Workspace assignments for monitors with workspace names
  workspaceAssignments = map (
    monitor:
    "workspace = ${monitor.hyprland.workspace.name}, monitor:${
      if builtins.isString monitor.name then monitor.name else "desc:${monitor.name.desc}"
    }"
  ) (filter (m: m.enabled && (m.hyprland.workspace.name or null) != null) cfg.monitors);

in
{
  # Export processed monitor configuration for home-manager
  config = mkIf (cfg.monitors != [ ]) {
    # Make monitor strings available to home-manager via environment or another mechanism
    # For now, let's use a custom option that home-manager can read
    environment.etc."hyprland-monitors.conf".text = ''
      # Generated monitor configuration for Hyprland
      ${lib.concatStringsSep "\n" (map (m: "monitor = ${m}") hyprlandMonitors)}
      ${lib.concatStringsSep "\n" workspaceAssignments}
    '';

    # Also make it available through system config for direct access
    system.build.hyprlandMonitorConfig = {
      monitors = hyprlandMonitors;
      workspaces = workspaceAssignments;
    };
  };
}
