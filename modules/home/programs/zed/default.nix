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
  imports = [
    ./settings
    ./keymaps.nix
    ./tasks.nix
    ./debug.nix
    ./themes.nix
  ];

  config = lib.mkIf cfg.enable {
    programs.zed-editor = {
      enable = true;

      extraPackages = lib.optionals modules.bundles.dev.nix.enable (
        with pkgs;
        [
          nixd
          nixfmt-rfc-style
        ]
      );
    };

    # TODO: Check if this is necessary
    # nixGL.vulkan.enable = true;

    home.sessionVariables.VISUAL = "zeditor --new --wait";
  };
}
