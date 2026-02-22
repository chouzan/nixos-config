{
  osConfig,
  lib,
  libs,
  ...
}:

let
  inherit (osConfig) modules;
  inherit (libs.mcp) servers;

  cfg = modules.programs.mcp;
in
{
  config = lib.mkIf cfg.enable {
    programs.mcp = {
      enable = true;

      servers = lib.mkMerge [
        (lib.mkIf cfg.servers.sequential-thinking.enable {
          "${servers.sequential-thinking.name}" = {
            inherit (servers.sequential-thinking) command args env;
          };
        })

        (lib.mkIf cfg.servers.context7.enable {
          "${servers.context7.name}" = {
            inherit (servers.context7) command args env;
          };
        })

        (lib.mkIf cfg.servers.graphiti-memory.enable {
          "${servers.graphiti-memory.name}" = {
            inherit (servers.graphiti-memory) command args env;
          };
        })

        (lib.mkIf cfg.servers.tidewave.enable {
          "${servers.tidewave.name}" = {
            inherit (servers.tidewave) command args env;
          };
        })
      ];
    };
  };
}
