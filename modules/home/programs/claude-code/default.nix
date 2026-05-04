{
  osConfig,
  lib,
  pkgs,
  ...
}:

let
  cfg = osConfig.modules.programs.claude-code;

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
  imports = [
    ./settings
  ];

  config = lib.mkIf cfg.enable {
    home.file = skillFiles // agentFiles;

    programs.claude-code = {
      enable = true;
      package = pkgs.claude-code-bun;
    };
  };
}
