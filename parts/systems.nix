{ inputs, ... }:

{
  systems = import inputs.systems;

  perSystem =
    { inputs', ... }:
    {
      _module.args.pkgs = inputs'.nixpkgs.legacyPackages;
    };
}
