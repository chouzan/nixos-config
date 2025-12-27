{
  osConfig,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  cfg = osConfig.modules.bundles;
  claudeDesktopPackages = inputs.claude-desktop.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  config = lib.mkIf cfg.ai.enable {
    home.packages = with pkgs; [
      mcp-proxy
      claudeDesktopPackages.claude-desktop
    ];
  };
}
