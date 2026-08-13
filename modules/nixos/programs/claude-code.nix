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

  cfg = modules.programs.claude-code;

  jsonFormat = pkgs.formats.json { };

  # Use the normal terminal foreground from Stylix. Without Stylix, omit ANSI
  # styling so the terminal supplies its default foreground.
  statusForeground = lib.optionalString modules.stylix.enable (
    let
      colour = config.lib.stylix.colors.base05;
      channel = offset: toString (lib.fromHexString (builtins.substring offset 2 colour));
    in
    "\\033[38;2;${channel 0};${channel 2};${channel 4}m"
  );

  statusReset = lib.optionalString modules.stylix.enable "\\033[0m";

  # Claude Code reports the model in the payload it writes to the status line.
  # The payload carries no effort level, but Claude Code writes the level to
  # the settings file when the user picks one, so it is read from there.
  statusSettings = ''"''${CLAUDE_CONFIG_DIR:-$HOME/.claude}/settings.json"'';

  modelSegment = pkgs.writeShellScript "claude-code-status-model" ''
    model=$(${lib.getExe pkgs.jq} -r '.model.display_name // empty' 2>/dev/null)
    [ -n "$model" ] || model=$(${lib.getExe pkgs.jq} -r '.model // empty' ${statusSettings} 2>/dev/null)

    [ -n "$model" ] && printf '${statusForeground}[%s]${statusReset}' "$model"

    exit 0
  '';

  effortSegment = pkgs.writeShellScript "claude-code-status-effort" ''
    effort=$(${lib.getExe pkgs.jq} -r '.effortLevel // empty' ${statusSettings} 2>/dev/null)

    [ -n "$effort" ] && printf '${statusForeground}[%s]${statusReset}' "$effort"

    exit 0
  '';

  # Claude Code runs one command for the status line, so the segments are
  # joined here. Each segment reads the same payload, because stdin can be
  # consumed only once. A segment that writes nothing leaves no gap.
  segments = lib.sort (a: b: a.order < b.order) cfg.statusLineSegments;

  statusLineScript = pkgs.writeShellScript "claude-code-statusline" ''
    payload=$(cat)
    output=""

    append() {
      [ -n "$1" ] || return 0
      if [ -z "$output" ]; then output=$1; else output="$output $1"; fi
    }

    ${lib.concatMapStringsSep "\n" (
      segment: ''append "$(printf '%s' "$payload" | ${segment.command})"''
    ) segments}

    printf '%s' "$output"

    # A non-zero status hides the whole bar, so end deliberately.
    exit 0
  '';

  managedSettings = lib.recursiveUpdate {
    permissions.deny = sensitivePaths.claudeDenyRules {
      inherit (modules.my) keyHome;
      inherit (modules.user) homeDirectory;
    };
  } cfg.systemSettings;
in
{
  # Policy only. Managed settings outrank every other layer and cannot be
  # overridden, which is what a deny list needs: nothing running as the user,
  # including the agent itself, can weaken it. Preferences do not belong here —
  # they are merged into the writable user settings by the home module.
  config = lib.mkIf cfg.enable {
    environment.etc."claude-code/managed-settings.json".source =
      jsonFormat.generate "claude-code-managed-settings.json" managedSettings;

    modules.programs.claude-code = {
      statusLineSegments = [
        {
          order = 10;
          command = "${modelSegment}";
        }

        {
          order = 20;
          command = "${effortSegment}";
        }
      ];

      userSettings.statusLine = lib.mkIf (segments != [ ]) {
        type = "command";
        command = "${statusLineScript}";
      };
    };
  };
}
