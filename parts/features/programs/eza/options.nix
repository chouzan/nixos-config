{
  flake.modules.nixos.programs-eza = { lib, ... }: {
    options.modules.programs.eza.enable =
      lib.mkEnableOption "eza (ls alternative) with custom configuration";
  };
}
