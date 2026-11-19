{
  flake.modules.nixos.hardware-battery = { lib, ... }: {
    options.modules.hardware.battery.enable = lib.mkEnableOption "battery optimization";
  };
}
