{ inputs, system, ... }:

[
  # Upstream overlays
  inputs.hyprland.overlays.hyprland-packages
  inputs.hyprtoolkit.overlays.default
  inputs.hyprpolkitagent.overlays.default

  # hyprpolkitagent upstream missing libglvnd — hyprgraphics.pc requires glesv2.
  # Remove this overlay once upstream adds libglvnd to buildInputs.
  (
    _final: prev:
    let
      hasGlesv2 = builtins.any (dep: (dep.pname or "") == "libglvnd") (
        prev.hyprpolkitagent.buildInputs or [ ]
      );
    in
    {
      hyprpolkitagent =
        if hasGlesv2 then
          builtins.warn "hyprpolkitagent: upstream now includes libglvnd. Remove the libglvnd workaround overlay in overlays/default.nix." prev.hyprpolkitagent
        else
          prev.hyprpolkitagent.overrideAttrs (old: {
            buildInputs = (old.buildInputs or [ ]) ++ [ prev.libglvnd ];
          });
    }
  )

  inputs.hyprpaper.overlays.default
  inputs.hypridle.overlays.default
  inputs.hyprlock.overlays.default
  inputs.hyprland-plugins.overlays.default

  # TODO: Maybe remove zed-editor flake
  # inputs.zed-editor.overlays.default

  inputs.claude-code.overlays.default
  inputs.claude-desktop.overlays.default

  # kitty #10102: recursive inotify watch on /nix/store via config symlinks.
  # Workaround: auto_reload_config = -1 in modules/home/desktop/hyprland/default.nix.
  # Remove both this overlay and that setting once kitty ships the fix.
  (_final: prev: {
    kitty =
      if builtins.compareVersions prev.kitty.version "0.48" >= 0 then
        builtins.warn "kitty: inotify watcher bug is likely fixed (>=0.48). Remove auto_reload_config workaround in modules/home/desktop/hyprland/default.nix and this overlay." prev.kitty
      else
        prev.kitty;
  })

  # Custom overlays (no upstream available)
  (import ./elixir-expert.nix { inherit inputs system; })
  (import ./mcp-proxy.nix { inherit inputs; })
]
