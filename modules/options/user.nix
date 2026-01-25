{
  config,
  lib,
  machine,
  ...
}:

let
  inherit (lib) types;
  inherit (machine) user;

  cfg = config.modules.user;
in
{
  options.modules.user = {
    enable = lib.mkOption {
      type = types.bool;
      default = true;
      description = "Whether to create the default user account.";
    };

    uid = lib.mkOption {
      type = types.int;
      default = 1000;
      example = 1001;
      description = "User's ID";
    };

    homeDirectory = lib.mkOption {
      type = types.str;
      default = "/home/${user.username}";
      example = "/home/bob";
      description = "User's home directory path";
    };

    runtimeDirectory = lib.mkOption {
      type = types.str;
      default = "/run/user/${toString cfg.uid}";
      example = "/run/user/1001";
      description = "XDG_RUNTIME_DIR path (system-managed, UID-based)";
    };
  };
}
