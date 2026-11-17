{ inputs, libs, ... }:

[
  # Upstream overlays
  inputs.hyprland.overlays.hyprland-packages
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

  # The screen share portal records a frame that the compositor failed and never
  # queues another one, so the share stops for good. Resizing the shared window
  # is enough to trigger it. Reported upstream as
  # hyprwm/xdg-desktop-portal-hyprland#445.
  #
  # The check reads the handlers without whitespace, so reformatting upstream
  # does not end the guard. It ends when the handler does more than record.
  (libs.utils.mkPackageGuardOverlay {
    pname = "xdg-desktop-portal-hyprland";
    overlayLocation = "overlays/default.nix";

    isBroken =
      pkg:
      let
        source = builtins.readFile "${pkg.src}/src/portals/Screencopy.cpp";
        compact = builtins.replaceStrings [ " " "\n" ] [ "" "" ] source;
      in
      inputs.nixpkgs.lib.hasInfix "sharingData.status=FRAME_FAILED;});" compact;

    fallback =
      _prev: pkg:
      pkg.overrideAttrs (old: {
        patches = (old.patches or [ ]) ++ [
          ./patches/xdg-desktop-portal-hyprland/failed-frame-recovery.patch
        ];
      });
  })

  inputs.hyprpaper.overlays.default
  inputs.hypridle.overlays.default
  inputs.hyprlock.overlays.default

  # TODO: Maybe remove zed-editor flake
  # inputs.zed-editor.overlays.default

  inputs.claude-code.overlays.default
  inputs.claude-desktop.overlays.default

  # Custom overlays (no upstream available)
  (import ./nu-writers.nix)
  (import ./nixosadm.nix)
  (import ./mcp-proxy.nix { inherit inputs; })
]
