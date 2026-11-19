{
  flake.modules.nixos.programs-starship = { lib, ... }: {
    options.modules.programs.starship.enable = lib.mkEnableOption "Starship cross-shell prompt";
  };
}
