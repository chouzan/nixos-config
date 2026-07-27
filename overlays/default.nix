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

  # Custom overlays (no upstream available)
  (import ./elixir-expert.nix { inherit inputs system; })
  (import ./mcp-proxy.nix { inherit inputs; })
]
