{ inputs, system, ... }:

[
  # Upstream overlays
  inputs.hyprland.overlays.default
  inputs.hyprpolkitagent.overlays.default
  inputs.hyprpaper.overlays.default
  inputs.hypridle.overlays.default
  inputs.hyprlock.overlays.default
  inputs.hyprland-plugins.overlays.default

  # TODO: Maybe remove zed-editor flake
  # inputs.zed-editor.overlays.default

  inputs.claude-code.overlays.default

  # Custom overlays (no upstream available)
  (import ./claude-code.nix { })
  (import ./claude-desktop.nix { inherit inputs system; })
  (import ./elixir-expert.nix { inherit inputs system; })
  (import ./less.nix { inherit inputs system; })
  (import ./mcp-proxy.nix { inherit inputs; })
]
