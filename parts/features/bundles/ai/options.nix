{
  flake.modules.nixos.bundles-ai = { lib, ... }: {
    options.modules.bundles.ai.enable = lib.mkEnableOption "AI tooling (Claude Desktop, MCP, etc.)";
  };
}
