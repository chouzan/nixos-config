{ osConfig, lib, ... }:

let
  cfg = osConfig.modules.programs.bat;
in
{
  config = lib.mkIf cfg.enable {
    programs.bat = {
      enable = true;

      config = {
        italic-text = "always";
        paging = "always";
        set-terminal-title = true;
        style = "full";
        wrap = "never";
      };
    };
  };
}
