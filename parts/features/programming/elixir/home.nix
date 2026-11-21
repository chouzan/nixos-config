{
  flake.modules.homeManager.programming-elixir =
    {
      osConfig,
      lib,
      pkgs,
      ...
    }:

    let
      cfg = osConfig.modules.programming;
    in
    {
      config = lib.mkMerge [
        (lib.mkIf cfg.elixir.enable {
          home.packages = with pkgs.beamPackages; [
            elixir
            expert
          ];
        })

        (lib.mkIf cfg.elixir.phoenix.enable {
          home.packages = with pkgs; [ inotify-tools ];
        })
      ];
    };
}
