{ lib, ... }:

{
  options.modules.hardware = {
    cpu.amd.enable = lib.mkEnableOption "AMD CPU configuration";
    gpu.amd.enable = lib.mkEnableOption "AMD GPU configuration";
    battery.enable = lib.mkEnableOption "battery optimization";
  };
}
