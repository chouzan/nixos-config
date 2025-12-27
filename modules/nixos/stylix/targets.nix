{ config, lib, ... }:

let
  cfg = config.modules.stylix;
in
{
  config = lib.mkIf cfg.enable {
    stylix = {
      autoEnable = true;

      targets = {
        grub.enable = false;
        qt.enable = false;
      };
    };
  };
}
