{
  config,
  lib,
  machine,
  ...
}:

let
  inherit (lib) types;
  inherit (machine) user;

  cfg = config.modules.my;
in
{
  options.modules.my = {
    home = lib.mkOption {
      type = types.str;
      default = "${user.homeDir}/.my";
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
