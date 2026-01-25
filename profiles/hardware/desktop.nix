{ libs, ... }:

let
  inherit (libs) utils;
in
{
  modules.hardware.battery.enable = utils.mkProfileDefault false;
}
