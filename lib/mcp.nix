{ ... }:

{
  servers = {
    sequential-thinking = {
      name = "sequential-thinking";
      command = "bunx";

      args = [
        "@modelcontextprotocol/server-sequential-thinking"
      ];

      env = { };
    };

    context7 = {
      name = "context7";
      command = "bunx";

      args = [
        "@upstash/context7-mcp"
      ];

      env = { };
    };

    graphiti-memory = {
      name = "graphiti-memory";
      command = "mcp-proxy";

      args = [
        "$GRAPHITI_MEMORY_URL"
      ];

      env = { };
    };

    tidewave = {
      name = "tidewave";
      command = "mcp-proxy";

      args = [
        "$TIDEWAVE_URL"
      ];

      env = { };
    };
  };
}
