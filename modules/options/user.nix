{ lib, machine, ... }:

let
  inherit (lib) types;
  inherit (machine) user;
in
{
  options.modules.user = {
    homeDirectory = lib.mkOption {
      type = types.str;
      default = "/home/${user.username}";
      example = "/home/bob";
      description = "User's home directory path";
    };

    runtimeDirectory = lib.mkOption {
      type = types.str;
      default = "/run/user/1000";
      example = "/run/user/1001";
      description = "XDG_RUNTIME_DIR path (system-managed, UID-based)";
    };
  };
}
