{
  flake.modules.homeManager.programs-zed =
    {
      osConfig,
      lib,
      pkgs,
      ...
    }:

    let
      inherit (osConfig) modules;
      cfg = modules.programs.zed;
    in
    {
      config = lib.mkIf cfg.enable {
        programs.zed-editor = {
          enable = true;

          extraPackages =
            with pkgs;
            lib.optionals modules.programming.nix.enable [
              nixd
              nixfmt
            ]
            ++ lib.optionals modules.programs.nushell.enable [
              nushell
              nufmt
            ];
        };

        # TODO: Check if this is necessary
        # nixGL.vulkan.enable = true;

        home.sessionVariables.VISUAL = "zeditor --new --wait";
      };
    };
}
