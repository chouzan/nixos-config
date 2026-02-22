{ osConfig, lib, ... }:

let
  inherit (osConfig) modules;

  cfg = modules.programs.opencode;
  mcpCfg = modules.programs.mcp;
in
{
  config = lib.mkIf cfg.enable {
    programs.opencode = {
      enable = true;
      enableMcpIntegration = mcpCfg.enable;
    };
  };
}
