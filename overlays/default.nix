{ inputs, system, ... }:

[
  (import ./mcp-proxy.nix { inherit inputs; })
  (import ./zed-editor.nix { inherit inputs system; })
]
