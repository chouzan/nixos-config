{
  flake.modules.homeManager.llm-claude-desktop =
    {
      osConfig,
      lib,
      pkgs,
      ...
    }:

    let
      cfg = osConfig.modules.llm.claude-desktop;
    in
    {
      config = lib.mkIf cfg.enable {
        # From claude-desktop overlay
        home.packages = [ pkgs.claude-desktop ];
      };
    };
}
