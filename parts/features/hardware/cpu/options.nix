{
  flake.modules.nixos.hardware-cpu = { lib, ... }: {
    options.modules.hardware.cpu.amd.enable = lib.mkEnableOption "AMD CPU configuration";
  };
}
