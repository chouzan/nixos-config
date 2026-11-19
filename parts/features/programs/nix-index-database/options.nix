{
  flake.modules.nixos.programs-nix-index-database = { lib, ... }: {
    options.modules.programs.nix-index-database.enable =
      lib.mkEnableOption "nix-index database with comma";
  };
}
