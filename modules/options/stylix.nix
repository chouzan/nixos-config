{ lib, ... }:

{
  options.modules.stylix.enable = lib.mkEnableOption "system-wide theming with Stylix";
}
