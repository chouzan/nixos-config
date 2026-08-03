{
  osConfig,
  inputs,
  lib,
  pkgs,
  ...
}:

let
  inherit (osConfig) modules;

  cfg = modules.programs.llm-plugins.caveman;
  caveman = inputs.llm-caveman;

  opencodePlugin = pkgs.runCommand "caveman-opencode-plugin" { } ''
    install -Dm644 ${caveman}/src/plugins/opencode/plugin.js \
      "$out/plugin.js"
    install -Dm644 ${caveman}/src/plugins/opencode/package.json \
      "$out/package.json"
    install -Dm644 ${caveman}/src/hooks/caveman-config.js \
      "$out/caveman-config.cjs"
  '';

  readMarkdownFiles =
    {
      directory,
      transform ? lib.id,
    }:
    lib.mapAttrs'
      (
        name: _:
        lib.nameValuePair (lib.removeSuffix ".md" name) (
          transform (builtins.readFile "${directory}/${name}")
        )
      )
      (
        lib.filterAttrs (name: type: type == "regular" && lib.hasSuffix ".md" name) (
          builtins.readDir directory
        )
      );

  readDirectories =
    directory:
    lib.mapAttrs (name: _: "${directory}/${name}") (
      lib.filterAttrs (_: type: type == "directory") (builtins.readDir directory)
    );

  # Caveman agents declare a `tools:` key for Claude Code's schema. OpenCode
  # rejects it and uses its default tool set when absent, so drop the key from
  # the frontmatter, including any indented block form, and leave the body
  # untouched. Dropping starts at a top-level `tools:` and continues through the
  # indented lines beneath it; a fence or a non-indented line ends it.
  stripClaudeTools =
    content:
    let
      indented = line: lib.hasPrefix " " line || lib.hasPrefix "\t" line;

      step =
        state: line:
        let
          atFence = line == "---" && state.fence < 2;
          inFrontmatter = state.fence == 1;

          dropping =
            inFrontmatter
            && !atFence
            && (if state.dropping then indented line else lib.hasPrefix "tools:" line);
        in
        {
          fence = if atFence then state.fence + 1 else state.fence;
          inherit dropping;
          out = if dropping then state.out else state.out ++ [ line ];
        };

      result = lib.foldl' step {
        fence = 0;
        dropping = false;
        out = [ ];
      } (lib.splitString "\n" content);
    in
    lib.concatStringsSep "\n" result.out;

  cavemanSkills = readDirectories "${caveman}/skills";

  opencodeCommands = readMarkdownFiles {
    directory = "${caveman}/src/plugins/opencode/commands";
  };

  opencodeAgents = readMarkdownFiles {
    directory = "${caveman}/agents";
    transform = stripClaudeTools;
  };
in
{
  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      (lib.mkIf modules.programs.claude-code.enable {
        programs.claude-code.plugins = { inherit caveman; };
      })

      (lib.mkIf modules.programs.codex.enable {
        programs.codex.skills = cavemanSkills;
      })

      (lib.mkIf modules.programs.opencode.enable {
        programs.opencode = {
          skills = cavemanSkills;
          commands = opencodeCommands;
          agents = opencodeAgents;

          settings = {
            instructions = [ "${caveman}/src/rules/caveman-activate.md" ];
            plugin = [ "./plugins/caveman/plugin.js" ];
          };
        };

        xdg.configFile."opencode/plugins/caveman" = {
          source = opencodePlugin;
          recursive = true;
        };
      })
    ]
  );
}
