{
  flake.modules.homeManager.programming-nix =
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
        (lib.mkIf cfg.nix.enable {
          home.packages = with pkgs; [
            nix-tree
            nix-output-monitor
          ];
        })
      ];
    };
}
