{
  flake.modules.nixos.base =
    { ... }:

    {
      # Allow unfree packages
      nixpkgs.config.allowUnfree = true;
    };
}
