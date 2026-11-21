{
  flake.modules.homeManager.programming-python =
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
        (lib.mkIf cfg.python.enable {
          home.packages = with pkgs; [ python3 ];
          programs.uv.enable = true;
        })
      ];
    };
}
