{ lib, utils }:

let
  toHyprlandMonitor =
    monitor:
    let
      inherit (monitor) name;

      resolution = "${toString monitor.width}x${toString monitor.height}@${toString monitor.refreshRate}";
      position = utils.orIfNull monitor.position monitor.hyprland.position;
      scale = toString monitor.scale;
      hyprlandOpts = monitor.hyprland;

      optionalArgs =
        lib.optional (hyprlandOpts.transform != 0) "transform, ${toString hyprlandOpts.transform}"
        ++ lib.optional (hyprlandOpts.mirror != null) "mirror, ${hyprlandOpts.mirror}"
        ++ lib.optional (hyprlandOpts.bitdepth != 8) "bitdepth, ${toString hyprlandOpts.bitdepth}"
        ++ lib.optional (hyprlandOpts.cm != "srgb") "cm, ${hyprlandOpts.cm}"
        ++ lib.optional (hyprlandOpts.vrr != 0) "vrr, ${toString hyprlandOpts.vrr}";

      base = [
        name
        resolution
        position
        scale
      ];
    in
    lib.concatStringsSep ", " (base ++ optionalArgs);

  getWorkspaceAssignments =
    monitors:
    lib.map (m: "name:${m.hyprland.workspace}, monitor:${m.name}, default:true") (
      lib.filter (m: m.hyprland.workspace != null) monitors
    );
in
{
  inherit getWorkspaceAssignments toHyprlandMonitor;
}
