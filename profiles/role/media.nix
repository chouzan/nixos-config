{ lib, ... }:

{
  modules = {
    packages.media.enable = lib.mkDefault true;

    programs = {
      firefox.enable = lib.mkDefault true;
      spotify.enable = lib.mkDefault true;
    };
  };
}
