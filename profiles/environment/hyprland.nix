{ libs, ... }:

let
  inherit (libs) utils;
in
{
  modules.desktop.hyprland.enable = utils.mkProfileDefault true;
}
