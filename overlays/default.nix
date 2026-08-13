{ inputs, system, ... }:

[
  # Upstream overlays
  inputs.hyprland.overlays.hyprland-packages

  # WORKAROUND: XDPH 1.4.1 predates the out-of-buffer fix (#424), and does not
  # coalesce animated resize renegotiation (#216). Remove each patch when its
  # fix reaches the packaged release.
  (_final: prev: {
    xdg-desktop-portal-hyprland = prev.xdg-desktop-portal-hyprland.overrideAttrs (old: {
      patches = (old.patches or [ ]) ++ [
        ./patches/xdg-desktop-portal-hyprland/resize-renegotiation.patch
        ./patches/xdg-desktop-portal-hyprland/out-of-buffer-retry.patch
      ];
    });
  })

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
  (import ./nu-writers.nix)
  (import ./elixir-expert.nix { inherit inputs system; })
  (import ./mcp-proxy.nix { inherit inputs; })
]
