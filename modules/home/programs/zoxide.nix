{ osConfig, lib, ... }:

let
  inherit (osConfig) modules;
  cfg = modules.programs.zoxide;
in
{
  config = lib.mkIf cfg.enable {
    programs.zoxide.enable = true;
  };
}
