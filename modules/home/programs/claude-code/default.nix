{
  osConfig,
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (osConfig) modules;

  cfg = modules.programs.claude-code;

  jsonFormat = pkgs.formats.json { };
  settingsPath = "${config.home.homeDirectory}/.claude/settings.json";

  userSettings = lib.recursiveUpdate {
    "$schema" = "https://json.schemastore.org/claude-code-settings.json";

    tui = "fullscreen";
    env.DISABLE_AUTOUPDATER = "1";

    attribution = {
      commit = "";
      pr = "";
      sessionUrl = false;
    };
  } cfg.userSettings;

  userSettingsFile = jsonFormat.generate "claude-code-user-settings.json" userSettings;

  # Claude Code owns this file: it writes runtime choices such as the model and
  # effort level back to it. Merge the declared preferences into whatever is
  # there instead of managing the file, so both survive. Declared values win on
  # conflict; keys dropped from the module stay until removed by hand.
  #
  # Must run after linkGeneration: the file may still be a symlink into the
  # store from an earlier generation, and writing through it would fail on the
  # read-only store. Home Manager removes it once it stops managing the file.
  #
  # Unreadable or malformed JSON aborts instead of falling back to an empty
  # object, which would drop every runtime value on the next write.
  mergeUserSettings = ''
    settings=${lib.escapeShellArg settingsPath}

    mkdir -p "$(dirname "$settings")"

    if [ ! -e "$settings" ]; then
      echo '{}' > "$settings"
    fi

    if ! dynamic="$(${lib.getExe pkgs.jq} '.' "$settings")"; then
      echo "claude-code: $settings is not valid JSON; fix or remove it" >&2
      exit 1
    fi

    merged="$(${lib.getExe pkgs.jq} -n '$dynamic * $static' \
      --argjson dynamic "$dynamic" \
      --argjson static "$(cat ${userSettingsFile})")"

    # Write through a temporary file so an interrupted run cannot truncate the
    # settings Claude Code is holding. Keep it private: the file carries the
    # environment Claude Code runs with, which is where a token would sit.
    (
      umask 077
      printf '%s\n' "$merged" > "$settings.tmp"
    )
    chmod 600 "$settings.tmp"
    mv "$settings.tmp" "$settings"
  '';

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

    home.activation.claudeCodeSettings = lib.hm.dag.entryAfter [ "linkGeneration" ] mergeUserSettings;

    programs.claude-code = {
      enable = true;
      enableMcpIntegration = mcpCfg.enable;

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

      # No `settings` here: home-manager would install the user settings file
      # read-only, and Claude Code writes runtime choices such as the model and
      # effort level to it. Declarative settings live in the managed layer (see
      # the nixos claude-code module).
    };
  };
}
