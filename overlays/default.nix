{ inputs, system, ... }:

[
  (import ./mcp-proxy.nix)
  (import ./zed-editor.nix { inherit inputs system; })
]
