{ osConfig, lib, ... }:

let
  cfg = osConfig.modules.programs.zed;
in
{
  config = lib.mkIf cfg.enable {
    programs.zed-editor.themes = { };
  };
}
