{ osConfig, lib, ... }:

let
  inherit (osConfig) modules;
  cfg = modules.programs.eza;
in
{
  config = lib.mkIf cfg.enable {
    programs.eza = {
      enable = true;
      enableZshIntegration = modules.programs.zsh.enable;
      git = true;
      icons = "auto";
    };
  };
}
