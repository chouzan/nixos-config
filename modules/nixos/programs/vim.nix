{ config, lib, ... }:

let
  cfg = config.modules.programs.vim;
in
{
  config = lib.mkIf cfg.enable {
    programs.vim = {
      enable = true;
      defaultEditor = true;
    };
  };
}
