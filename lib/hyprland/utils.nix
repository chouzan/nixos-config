{ lib, utils }:

let
  # An `hl.monitor({ ... })` argument table; optional keys are omitted at their
  # defaults.
  mkMonitor =
    {
      output,
      mode,
      position,
      scale,
      transform ? 0,
      mirror ? null,
      bitdepth ? 8,
      cm ? "srgb",
      vrr ? 0,
    }:
    {
      inherit
        output
        mode
        position
        scale
        ;
    }
    // lib.optionalAttrs (transform != 0) { inherit transform; }
    // lib.optionalAttrs (mirror != null) { inherit mirror; }
    // lib.optionalAttrs (bitdepth != 8) { inherit bitdepth; }
    // lib.optionalAttrs (cm != "srgb") { inherit cm; }
    // lib.optionalAttrs (vrr != 0) { inherit vrr; };

  # A configured monitor (`modules.monitors` entry) as an `hl.monitor` table.
  toHyprlandMonitor =
    monitor:
    mkMonitor {
      inherit (monitor) scale;

      inherit (monitor.hyprland)
        transform
        mirror
        bitdepth
        cm
        vrr
        ;

      output = monitor.name;
      mode = "${toString monitor.width}x${toString monitor.height}@${toString monitor.refreshRate}";
      position = utils.orIfNull monitor.position monitor.hyprland.position;
    };

  # Per-monitor default workspace as an `hl.workspace_rule({ ... })` table.
  getWorkspaceAssignments =
    monitors:
    lib.map (m: {
      workspace = "name:${m.hyprland.workspace}";
      monitor = m.name;
      default = true;
    }) (lib.filter (m: m.hyprland.workspace != null) monitors);

  # `hl.env(name, value)`.
  mkEnv = name: value: {
    _args = [
      name
      value
    ];
  };

  # Wrap a Hyprland dispatcher expression as a `hyprctl dispatch` command.
  # `hyprctl dispatch` evaluates its argument as lua, so single-quote any
  # strings inside `expr` to keep the shell quoting clean.
  hlDispatch = expr: ''hyprctl dispatch "${expr}"'';
in
{
  inherit
    getWorkspaceAssignments
    hlDispatch
    mkEnv
    mkMonitor
    toHyprlandMonitor
    ;
}
