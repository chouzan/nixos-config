{
  osConfig,
  lib,
  pkgs,
  ...
}:

let
  cfg = osConfig.modules.programs.firefox;
in
{
  config = lib.mkIf cfg.enable {
    programs.firefox.profiles.default = {
      settings."svg.context-properties.content.enabled" = true;

      extensions = {
        packages = with pkgs.nur.repos.rycee.firefox-addons; [ simple-tab-groups ];

        settings."simple-tab-groups@drive4ik" = {
          force = true;
          settings = builtins.fromJSON (builtins.readFile ./simple-tab-groups-settings.json);
        };
      };
    };
  };
}
