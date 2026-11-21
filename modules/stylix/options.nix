{
  flake.modules.nixos.stylix = { lib, ... }: {
    options.modules.stylix.enable = lib.mkEnableOption "system-wide theming with Stylix";
  };
}
