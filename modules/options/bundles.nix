{ lib, ... }:

{
  options.modules.bundles = {
    container.enable = lib.mkEnableOption "container and virtualization tools (podman, podman-compose)";
    ai.enable = lib.mkEnableOption "AI tooling (Claude Desktop, MCP, etc.)";

    dev = {
      enable = lib.mkEnableOption "uncategorized development tools";
      nix.enable = lib.mkEnableOption "Nix development";
      ruby.enable = lib.mkEnableOption "Ruby development";
      python.enable = lib.mkEnableOption "Python development";
      node.enable = lib.mkEnableOption "Node.js development";

      elixir = {
        enable = lib.mkEnableOption "Elixir development";
        phoenix.enable = lib.mkEnableOption "Phoenix framework development";
      };
    };
  };
}
