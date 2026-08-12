{ osConfig, lib, ... }:

let
  inherit (osConfig) modules;
  cfg = modules.programs.eza;
in
{
  config = lib.mkIf cfg.enable {
    programs.eza = {
      enable = true;
      git = true;
      icons = "auto";
    };
  };
}
