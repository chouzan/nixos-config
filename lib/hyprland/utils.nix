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
        lib.optional (hyprlandOpts.rotate != 0) "transform, ${toString hyprlandOpts.rotate}"
        ++ lib.optional (hyprlandOpts.mirror != null) "mirror, ${hyprlandOpts.mirror}"
        ++ lib.optional (hyprlandOpts.vrr != 0) "vrr, ${toString hyprlandOpts.vrr}"
        ++ lib.optional (hyprlandOpts.colour != "auto") "cm, ${toString hyprlandOpts.colour}";

      extraArgs = lib.concatStringsSep ", " optionalArgs;
    in
    lib.concatStringsSep ", " [
      name
      resolution
      position
      scale
      extraArgs
    ];

  getWorkspaceAssignments =
    monitors:
    lib.map (m: "name:${m.hyprland.workspace}, monitor:${m.name}, default:true") (
      lib.filter (m: m.hyprland.workspace != null) monitors
    );
in
{
  inherit getWorkspaceAssignments toHyprlandMonitor;
}
