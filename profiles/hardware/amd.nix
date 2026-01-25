{ libs, ... }:

let
  inherit (libs) utils;
in
{
  modules.hardware = {
    cpu.amd.enable = utils.mkProfileDefault true;
    gpu.amd.enable = utils.mkProfileDefault true;
  };
}
