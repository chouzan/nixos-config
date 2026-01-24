{ inputs, system, ... }:

[
  # Upstream overlays
  inputs.hyprland.overlays.default
  inputs.hyprpolkitagent.overlays.default
  inputs.hyprpaper.overlays.default
  inputs.hypridle.overlays.default
  inputs.hyprlock.overlays.default
  inputs.hyprland-plugins.overlays.default

  # Custom overlays (no upstream available)
  (import ./claude-desktop.nix { inherit inputs system; })
  (import ./mcp-proxy.nix { inherit inputs; })
  (import ./zed-editor.nix { inherit inputs system; })
]
