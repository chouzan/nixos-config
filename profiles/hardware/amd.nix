{ lib, ... }:

{
  modules.hardware = {
    cpu.amd.enable = lib.mkDefault true;
    gpu.amd.enable = lib.mkDefault true;
  };
}
