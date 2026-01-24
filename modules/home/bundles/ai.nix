{
  osConfig,
  lib,
  pkgs,
  ...
}:

let
  cfg = osConfig.modules.bundles;
in
{
  config = lib.mkIf cfg.ai.enable {
    home.packages = with pkgs; [
      # From claude-desktop overlay
      claude-desktop

      # From mcp-proxy overlay
      mcp-proxy
    ];
  };
}
