{ osConfig, lib, ... }:

let
  cfg = osConfig.modules.stylix;
in
{
  config = lib.mkIf cfg.enable {
    stylix = {
      autoEnable = true;

      targets = {
        firefox.enable = false;
        kde.enable = false;
        opencode.enable = false;
        qt.enable = osConfig.stylix.targets.qt.enable;
      };
    };
  };
}
