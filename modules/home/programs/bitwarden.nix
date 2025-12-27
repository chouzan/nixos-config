{
  osConfig,
  lib,
  pkgs,
  ...
}:

let
  cfg = osConfig.modules.programs.bitwarden;
in
{
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [ bitwarden-desktop ];
  };
}
