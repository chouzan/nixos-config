{
  flake.modules.homeManager.programming-tools =
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
        (lib.mkIf cfg.tools.enable {
          home.packages = with pkgs; [
            devenv
            git-lfs
          ];

          programs.direnv = {
            enable = true;
            nix-direnv.enable = cfg.nix.enable;
          };
        })
      ];
    };
}
