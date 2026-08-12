{ config, lib, ... }:

let
  cfg = config.modules.programs.nushell;
in
{
  config = lib.mkIf cfg.enable {
    programs.nushell.enable = true;
  };
}
