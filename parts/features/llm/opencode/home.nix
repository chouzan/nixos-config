{
  flake.modules.homeManager.llm-opencode =
    { osConfig, lib, ... }:

    let
      inherit (osConfig) modules;

      cfg = modules.llm.opencode;
      mcpCfg = modules.llm.mcp;
    in
    {
      config = lib.mkIf cfg.enable {
        programs.opencode = {
          enable = true;
          enableMcpIntegration = mcpCfg.enable;

          settings = {
            lsp = {
              elixir-ls.disabled = true;

              elixir-expert = {
                command = [
                  "expert"
                  "--stdio"
                ];

                extensions = [
                  ".ex"
                  ".exs"
                  ".heex"
                ];
              };
            };
          };
        };
      };
    };
}
