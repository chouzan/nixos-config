{ osConfig, lib, ... }:

let
  cfg = osConfig.modules.programs.gh;
in
{
  config = lib.mkIf cfg.enable {
    programs.gh.enable = true;
  };
}
