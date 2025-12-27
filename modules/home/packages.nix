{
  osConfig,
  lib,
  pkgs,
  ...
}:

let
  cfg = osConfig.modules.packages;
in
{
  config = lib.mkMerge [
    (lib.mkIf cfg.admin.enable {
      home.packages = with pkgs; [ btop ];
    })

    (lib.mkIf cfg.cli.enable {
      home.packages = with pkgs; [
        duf
        dust
        fastfetch
        fd
        fx
      ];
    })

    (lib.mkIf cfg.archive.enable {
      home.packages = with pkgs; [ atool ];
    })

    (lib.mkIf cfg.media.enable {
      home.packages = with pkgs; [
        ffmpeg
        imagemagick
      ];
    })
  ];
}
