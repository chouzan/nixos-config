{ libs, ... }:

let
  inherit (libs) utils;
in
{
  modules = {
    system.xdg.enable = utils.mkProfileDefault true;
    stylix.enable = utils.mkProfileDefault true;
  };
}
