{ inputs, libs, ... }:

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

  # hyprgraphics.pc requires glesv2, which hyprpolkitagent does not declare.
  (libs.utils.mkPackageGuardOverlay {
    pname = "hyprpolkitagent";
    overlayLocation = "overlays/default.nix";

    isBroken = pkg: !(builtins.any (dep: (dep.pname or "") == "libglvnd") (pkg.buildInputs or [ ]));

    fallback =
      prev: pkg:
      pkg.overrideAttrs (old: {
        buildInputs = (old.buildInputs or [ ]) ++ [ prev.libglvnd ];
      });
  })

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
  (import ./mcp-proxy.nix { inherit inputs; })
]
