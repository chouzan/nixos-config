{ lib, ... }:

{
  modules.hardware.battery.enable = lib.mkDefault true;
}
