{
  osConfig,
  lib,
  libs,
  pkgs,
  ...
}:

let
  inherit (libs.mcp) servers;

  cfg = osConfig.modules.programs.claude-code;

  skills = [
    ./skills/skill-creator
  ];

  skillFiles = lib.listToAttrs (
    map (
      source:
      lib.nameValuePair ".claude/skills/${baseNameOf source}" {
        inherit source;
        recursive = true;
      }
    ) skills
  );
in
{
  config = lib.mkIf cfg.enable {
    home.file = skillFiles;

    programs.claude-code = {
      enable = true;
      package = pkgs.claude-code-bun;

      mcpServers = {
        "${servers.sequential-thinking.name}" = {
          inherit (servers.sequential-thinking) command args env;
          type = "stdio";
        };

        "${servers.context7.name}" = {
          inherit (servers.context7) command args env;
          type = "stdio";
        };

        "${servers.graphiti-memory.name}" = {
          inherit (servers.graphiti-memory) command args env;
          type = "stdio";
        };

        "${servers.tidewave.name}" = {
          inherit (servers.tidewave) command args env;
          type = "stdio";
        };
      };
    };
  };
}
