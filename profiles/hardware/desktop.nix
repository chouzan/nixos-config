{ lib, ... }:

{
  modules.hardware.battery.enable = lib.mkDefault false;
}
