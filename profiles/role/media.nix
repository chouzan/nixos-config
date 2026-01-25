{ libs, ... }:

let
  inherit (libs) utils;
in
{
  modules = {
    packages.media.enable = utils.mkProfileDefault true;

    programs = {
      firefox.enable = utils.mkProfileDefault true;
      spotify.enable = utils.mkProfileDefault true;
    };
  };
}
