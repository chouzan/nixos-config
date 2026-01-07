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
    programs.firefox.profiles.default.extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
      bitwarden
      simple-tab-groups
      ublock-origin
      privacy-badger
      decentraleyes
      sponsorblock
      languagetool
      web-clipper-obsidian
      search-by-image
    ];
  };
}
