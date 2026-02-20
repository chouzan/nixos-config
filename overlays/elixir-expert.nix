{ inputs, system, ... }:

_final: _prev: {
  elixir-expert = inputs.elixir-expert.packages.${system}.expert;
}
