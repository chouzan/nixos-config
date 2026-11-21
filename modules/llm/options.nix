{
  flake.modules.nixos.llm-options = { lib, pkgs, ... }: {
    options.modules.llm = {
      mcp = {
        enable = lib.mkEnableOption "MCP server configuration";

        servers = {
          sequential-thinking.enable = lib.mkEnableOption "sequential-thinking MCP server";
          context7.enable = lib.mkEnableOption "context7 MCP server";
          graphiti-memory.enable = lib.mkEnableOption "graphiti-memory MCP server";
          tidewave.enable = lib.mkEnableOption "tidewave MCP server";
        };
      };

      claude-code = {
        enable = lib.mkEnableOption "Claude Code agentic coding tool";

        systemSettings = lib.mkOption {
          inherit (pkgs.formats.json { }) type;
          default = { };
          internal = true;
          description = "Composable policy for the Claude Code managed settings layer";
        };

        userSettings = lib.mkOption {
          inherit (pkgs.formats.json { }) type;
          default = { };
          internal = true;
          description = "Composable preferences merged into the writable Claude Code user settings";
        };

        statusLineSegments = lib.mkOption {
          type = lib.types.listOf (
            lib.types.submodule {
              options = {
                order = lib.mkOption {
                  type = lib.types.int;
                  default = 100;
                  description = "Sort key. A lower value puts the segment further left.";
                };

                command = lib.mkOption {
                  type = lib.types.str;
                  description = "Command that reads the status payload on stdin and writes one segment.";
                };
              };
            }
          );

          default = [ ];
          internal = true;
          description = "Composable segments for the Claude Code status line";
        };
      };

      codex = {
        enable = lib.mkEnableOption "Codex CLI agentic coding tool";

        systemSettings = lib.mkOption {
          inherit (pkgs.formats.toml { }) type;
          default = { };
          internal = true;
          description = "Composable settings for the Codex System configuration layer";
        };
      };

      opencode.enable = lib.mkEnableOption "OpenCode agentic coding tool";
      caveman.enable = lib.mkEnableOption "Caveman workflow plugin for LLM coding agents";
      claude-desktop.enable = lib.mkEnableOption "Claude Desktop";
    };
  };
}
