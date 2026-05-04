{
  osConfig,
  lib,
  libs,
  ...
}:

let
  inherit (osConfig) modules;
  inherit (libs.mcp) servers;

  mcpCfg = modules.programs.mcp;
in
{
  config = lib.mkIf modules.programs.claude-code.enable {
    programs.claude-code.mcpServers = lib.mkMerge [
      (lib.mkIf mcpCfg.servers.sequential-thinking.enable {
        "${servers.sequential-thinking.name}" = {
          inherit (servers.sequential-thinking) command args env;
          type = "stdio";
        };
      })

      (lib.mkIf mcpCfg.servers.context7.enable {
        "${servers.context7.name}" = {
          inherit (servers.context7) command args env;
          type = "stdio";
        };
      })

      (lib.mkIf mcpCfg.servers.graphiti-memory.enable {
        "${servers.graphiti-memory.name}" = {
          inherit (servers.graphiti-memory) command args env;
          type = "stdio";
        };
      })

      (lib.mkIf mcpCfg.servers.tidewave.enable {
        "${servers.tidewave.name}" = {
          inherit (servers.tidewave) command args env;
          type = "stdio";
        };
      })
    ];
  };
}
