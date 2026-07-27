{ osConfig, lib, ... }:

let
  inherit (osConfig) modules;
  cfg = modules.programs.starship;
in
{
  config = lib.mkIf cfg.enable {
    programs.starship = {
      enable = true;
      enableZshIntegration = modules.programs.zsh.enable;
      settings = fromTOML (builtins.readFile ./settings.toml);
    };
  };
}
