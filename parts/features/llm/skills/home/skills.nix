{
  flake.modules.homeManager.llm-skills =
    { osConfig, lib, ... }:

    let
      inherit (osConfig) modules;

      skills = {
        skill-creator = ./skill-creator;
        change-description = ./change-description;
        technical-writing = ./technical-writing;
      };
    in
    {
      config = lib.mkMerge [
        (lib.mkIf modules.llm.claude-code.enable {
          programs.claude-code.skills = skills;
        })

        (lib.mkIf modules.llm.codex.enable {
          programs.codex.skills = skills;
        })

        (lib.mkIf modules.llm.opencode.enable {
          programs.opencode.skills = skills;
        })
      ];
    };
}
