{
  flake.modules.nixos.programs-nushell = { lib, ... }: {
    options.modules.programs.nushell.enable = lib.mkEnableOption "Nushell with custom configuration";
  };
}
