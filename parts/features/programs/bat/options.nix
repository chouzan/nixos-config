{
  flake.modules.nixos.programs-bat = { lib, ... }: {
    options.modules.programs.bat.enable =
      lib.mkEnableOption "bat (cat alternative) with custom configuration";
  };
}
