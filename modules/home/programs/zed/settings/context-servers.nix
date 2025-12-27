{
  osConfig,
  lib,
  libs,
  ...
}:

let
  inherit (libs.mcp) servers;
  cfg = osConfig.modules.programs.zed;
in
{
  config = lib.mkIf cfg.enable {
    programs.zed-editor.userSettings.context_servers = {
      "${servers.sequential-thinking.name}" = {
        inherit (servers.sequential-thinking) command args env;
        enabled = true;
      };

      "${servers.context7.name}" = {
        inherit (servers.context7) command args env;
        enabled = true;
      };

      "${servers.graphiti-memory.name}" = {
        inherit (servers.graphiti-memory) command args env;
        enabled = true;
      };

      "${servers.tidewave.name}" = {
        inherit (servers.tidewave) command args env;
        enabled = true;
      };
    };
  };
}
