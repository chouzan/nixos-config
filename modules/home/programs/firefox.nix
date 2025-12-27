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
    programs.firefox = {
      enable = true;

      profiles.default = {
        id = 0;
        name = "default";
        path = "92oz7e9w.default";
        isDefault = true;

        extensions = {
          packages = with pkgs.nur.repos.rycee.firefox-addons; [
            bitwarden
            decentraleyes
            languagetool
            multi-account-containers
            privacy-badger
            search-by-image
            simple-tab-groups
            sponsorblock
            ublock-origin
            web-clipper-obsidian
          ];
        };
      };
    };
  };
}
