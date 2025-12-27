{ lib, ... }:

{
  options.modules.packages = {
    admin.enable = lib.mkEnableOption "system administration and hardware diagnostic tools";
    network.enable = lib.mkEnableOption "network utilities (curl, wget, dig, etc.)";
    archive.enable = lib.mkEnableOption "archive and compression utilities (zip, 7z, etc.)";
    cli.enable = lib.mkEnableOption "CLI productivity tools (bat, eza, fzf, jq, etc.)";
    media.enable = lib.mkEnableOption "media processing tools (ffmpeg, imagemagick)";
    extras.enable = lib.mkEnableOption "optional package collections";
  };
}
