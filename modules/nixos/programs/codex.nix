{
  config,
  lib,
  pkgs,
  libs,
  ...
}:

let
  inherit (config) modules;
  inherit (libs) sensitivePaths;

  cfg = modules.programs.codex;
  mcpCfg = modules.programs.mcp;

  tomlFormat = pkgs.formats.toml { };

  # Build the MCP servers here from the shared libs.mcp data. Home-manager's
  # `enableMcpIntegration` would instead write them into the user config.toml,
  # which Codex must own and keep writable (see the System-layer note below).
  # Selection follows the same per-server enable flags the other agents use.
  # Commands are taken verbatim, so a bare command like `mcp-proxy` has to be
  # on Codex's PATH at runtime.
  enabledServers = lib.filterAttrs (
    name: _: mcpCfg.enable && (mcpCfg.servers.${name}.enable or false)
  ) libs.mcp.servers;

  mcpServers = lib.mapAttrs' (
    _: server:
    lib.nameValuePair server.name (
      {
        inherit (server) command args;
      }
      // lib.optionalAttrs (server.env != { }) { inherit (server) env; }
    )
  ) enabledServers;

  baseCodexConfig = lib.recursiveUpdate {
    # `default_permissions` selects the active permission profile and is
    # mutually exclusive with `sandbox_mode`/`sandbox_workspace_write`. A
    # bare name selects the custom profile below, which extends the
    # built-in `:workspace` profile with sensitive-path denies. Selecting
    # `:workspace` directly would bypass those additional rules.
    default_permissions = "workspace";

    permissions.workspace = {
      extends = ":workspace";

      filesystem =
        lib.recursiveUpdate
          {
            ":workspace_roots".".git" = "write";
            "~/.config/jj/repos" = "write";
            "~/.config/jj/workspaces" = "write";
            glob_scan_max_depth = 4;
          }
          (
            sensitivePaths.codexDenyEntries {
              inherit (modules.my) keyHome;
              inherit (modules.user) homeDirectory;
            }
          );
    };

    check_for_update_on_startup = false;
    analytics.enabled = false;
    tui.notifications = true;

    # Still experimental upstream (`codex features list`), so expect churn.
    features.memories = true;
  } (lib.optionalAttrs (mcpServers != { }) { mcp_servers = mcpServers; });

  codexConfig = lib.recursiveUpdate baseCodexConfig cfg.systemSettings;
in
{
  # Codex writes folder-trust decisions to the user's config.toml at runtime,
  # so that file must stay writable and codex-owned; home-manager leaves it
  # unmanaged (see modules/home/programs/codex.nix). This declarative config
  # lives in Codex's `System` layer (/etc/codex/config.toml): lowest
  # precedence, always loaded for every subcommand, and merged beneath the
  # writable user file so the two never collide. A `--profile` layer cannot
  # replace it -- Codex rejects `--profile` on non-runtime subcommands such as
  # `doctor` and `login`.
  config = lib.mkIf cfg.enable {
    environment.etc."codex/config.toml".source = tomlFormat.generate "codex-config.toml" codexConfig;
  };
}
