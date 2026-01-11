{ inputs, system, ... }:

_final: _prev: {
  zed-editor = inputs.zed-editor.packages.${system}.default;
}
