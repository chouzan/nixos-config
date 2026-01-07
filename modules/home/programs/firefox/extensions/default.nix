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
    programs.firefox.profiles.default.extensions = {
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
}
