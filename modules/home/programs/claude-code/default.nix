{
  osConfig,
  lib,
  pkgs,
  ...
}:

let
  inherit (osConfig) modules;

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

  cavemanPlugin = pkgs.fetchFromGitHub {
    owner = "JuliusBrussee";
    repo = "caveman";
    rev = "25d22f864ad68cc447a4cb93aefde918aa4aec9f";
    hash = "sha256-FbmfhFaPs/SnSZdfNdErdIUHXt1FfBzErpPpLy8kdIc=";
  };
in
{
  config = lib.mkIf cfg.enable {
    home.file = skillFiles // agentFiles;

    programs.claude-code = {
      enable = true;
      enableMcpIntegration = mcpCfg.enable;

      plugins = [
        cavemanPlugin
      ];

      # Disabled: Claude Code LSP client has lifecycle bugs that wedge
      # the entire session. Re-enable once upstream fixes land.
      # Tracking:
      #   - github.com/anthropics/claude-code/issues/67037 (state gate wedges, blocks session)
      #   - github.com/anthropics/claude-code/issues/66987 (plugin LSP init-ordering bug)
      #   - github.com/anthropics/claude-code/issues/70326 (workspace/configuration never sent)
      #
      # lspServers = {
      #   nix = {
      #     command = "nixd";
      #     args = [ ];
      #
      #     extensionToLanguage = {
      #       ".nix" = "nix";
      #     };
      #   };
      #
      #   elixir = {
      #     command = "expert";
      #     args = [ "--stdio" ];
      #
      #     extensionToLanguage = {
      #       ".ex" = "elixir";
      #       ".exs" = "elixir";
      #       ".heex" = "phoenix-heex";
      #       ".leex" = "phoenix-heex";
      #     };
      #   };
      # };

      settings = {
        tui = "fullscreen";
        effortLevel = "xhigh";

        statusLine = {
          type = "command";
          command = "bash \"${cavemanPlugin}/src/hooks/caveman-statusline.sh\"";
        };

        attribution = {
          commit = "";
          pr = "";
          sessionUrl = false;
        };

        permissions = {
          deny = [
            "Read(.secrets/**)"
            "Read(.env)"
            "Read(.env.*)"
            "Read(**/*.key)"
            "Read(**/*.pem)"
            "Read(**/*.age)"
            "Read(**/credentials.json)"
          ];
        };
      };
    };
  };
}
