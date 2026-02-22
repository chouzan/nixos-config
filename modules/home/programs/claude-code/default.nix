{
  osConfig,
  lib,
  libs,
  pkgs,
  ...
}:

let
  inherit (osConfig) modules;
  inherit (libs.mcp) servers;

  cfg = modules.programs.claude-code;
  mcpCfg = modules.programs.mcp;

  skills = [
    ./skills/git-commit
    ./skills/git-rebase
    ./skills/nix-patterns
    ./skills/skill-creator
  ];

  agents = [
    ./agents/git-rebaser.md
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

  agentFiles = lib.listToAttrs (
    map (
      source:
      lib.nameValuePair ".claude/agents/${baseNameOf source}" {
        inherit source;
      }
    ) agents
  );
in
{
  config = lib.mkIf cfg.enable {
    home.file = skillFiles // agentFiles;

    programs.claude-code = {
      enable = true;
      package = pkgs.claude-code-bun;

      mcpServers = lib.mkMerge [
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
  };
}
