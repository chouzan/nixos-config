{ config, lib, ... }:

let
  inherit (config) modules;
  inherit (lib) types;

  cfg = modules.my;
in
{
  options.modules.my = {
    home = lib.mkOption {
      type = types.str;
      default = "${modules.user.homeDirectory}/.my";
    };

    scriptHome = lib.mkOption {
      type = types.str;
      default = "${cfg.home}/scripts";
    };

    keyHome = lib.mkOption {
      type = types.str;
      default = "${cfg.home}/keys";
    };
  };
}
