{ inputs, ... }:

{
  imports = [
    inputs.flake-parts.flakeModules.modules
    (inputs.import-tree ../modules)
  ];
}
