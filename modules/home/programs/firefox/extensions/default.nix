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
  imports = [
    ./simple-tab-groups.nix
  ];

  config = lib.mkIf cfg.enable {
    programs.firefox.profiles.default = {
      settings."extensions.autoDisableScopes" = 0;

      extensions = {
        force = true;

        packages = with pkgs.nur.repos.rycee.firefox-addons; [
          bitwarden
          ublock-origin
          privacy-badger
          decentraleyes
          sponsorblock
          languagetool
          web-clipper-obsidian
          search-by-image
        ];
      };
    };
  };
}
