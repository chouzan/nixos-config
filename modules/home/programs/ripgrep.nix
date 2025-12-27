{ osConfig, lib, ... }:

let
  cfg = osConfig.modules.programs.ripgrep;
in
{
  config = lib.mkIf cfg.enable {
    programs = {
      ripgrep.enable = true;

      # ripgrep-all is a companion tool that extends ripgrep
      ripgrep-all.enable = true;
    };
  };
}
