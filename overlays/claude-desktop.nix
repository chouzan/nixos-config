{ inputs, system, ... }:

_final: _prev: {
  inherit (inputs.claude-desktop.packages.${system}) claude-desktop;
}
