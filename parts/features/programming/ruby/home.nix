{
  flake.modules.homeManager.programming-ruby =
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
        (lib.mkIf cfg.ruby.enable {
          home.packages = with pkgs; [ ruby ];
        })
      ];
    };
}
