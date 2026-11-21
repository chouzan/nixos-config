{
  flake.modules.homeManager.programming-node =
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
        (lib.mkIf cfg.node.enable {
          home.packages = with pkgs; [ nodejs ];
          programs.bun.enable = true;
        })
      ];
    };
}
