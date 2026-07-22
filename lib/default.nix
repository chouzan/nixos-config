{ lib }:

rec {
  utils = import ./utils.nix { inherit lib; };
  hyprland = import ./hyprland { inherit lib utils; };
  mcp = import ./mcp.nix { };
  sensitivePaths = import ./sensitive-paths.nix { inherit lib; };
}
