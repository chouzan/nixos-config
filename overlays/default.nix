{ inputs, system, ... }:

[
  (import ./claude-desktop.nix { inherit inputs system; })
  (import ./mcp-proxy.nix { inherit inputs; })
  (import ./zed-editor.nix { inherit inputs system; })
]
