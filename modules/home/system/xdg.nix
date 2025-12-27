{
  osConfig,
  lib,
  machine,
  ...
}:

let
  inherit (machine) user;
  cfg = osConfig.modules.system;
in
{
  config = lib.mkIf cfg.xdg.enable {
    xdg = {
      enable = true;

      inherit (user)
        dataHome
        stateHome
        configHome
        cacheHome
        ;

      userDirs = {
        enable = true;
        createDirectories = true;
      };
    };
  };
}
