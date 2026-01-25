{
  osConfig,
  config,
  lib,
  ...
}:

let
  cfg = osConfig.modules.system;
  home = config.home.homeDirectory;
in
{
  config = lib.mkIf cfg.xdg.enable {
    xdg = {
      enable = true;

      # Reference: https://specifications.freedesktop.org/basedir-spec/latest/
      dataHome = "${home}/.local/share";
      configHome = "${home}/.config";
      stateHome = "${home}/.local/state";
      cacheHome = "${home}/.cache";

      userDirs = {
        enable = true;
        createDirectories = true;

        extraConfig = {
          XDG_MISC_DIR = "${home}/Misc";
        };
      };
    };
  };
}
