{ osConfig, lib, ... }:

let
  inherit (osConfig) modules;
  cfg = modules.programs.starship;
in
{
  config = lib.mkIf cfg.enable {
    programs.starship = {
      enable = true;
      settings = fromTOML (builtins.readFile ./settings.toml);
    };
  };
}
