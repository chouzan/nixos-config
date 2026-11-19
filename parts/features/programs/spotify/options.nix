{
  flake.modules.nixos.programs-spotify = { lib, ... }: {
    options.modules.programs.spotify.enable = lib.mkEnableOption "Spotify music player";
  };
}
