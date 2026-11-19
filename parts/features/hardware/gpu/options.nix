{
  flake.modules.nixos.hardware-gpu = { lib, ... }: {
    options.modules.hardware.gpu.amd.enable = lib.mkEnableOption "AMD GPU configuration";
  };
}
