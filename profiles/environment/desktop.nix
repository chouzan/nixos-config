{ lib, ... }:

{
  modules = {
    system.xdg.enable = lib.mkDefault true;
    stylix.enable = lib.mkDefault true;
  };
}
