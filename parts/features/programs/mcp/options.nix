{
  flake.modules.nixos.programs-mcp = { lib, ... }: {
    options.modules.programs.mcp = {
      enable = lib.mkEnableOption "MCP server configuration";

      servers = {
        sequential-thinking.enable = lib.mkEnableOption "sequential-thinking MCP server";
        context7.enable = lib.mkEnableOption "context7 MCP server";
        graphiti-memory.enable = lib.mkEnableOption "graphiti-memory MCP server";
        tidewave.enable = lib.mkEnableOption "tidewave MCP server";
      };
    };
  };
}
