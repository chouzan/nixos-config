{ osConfig, lib, ... }:

let
  inherit (osConfig) modules;

  skills = {
    change-description = ./change-description;
    technical-writing = ./technical-writing;
  };
in
{
  config = lib.mkMerge [
    (lib.mkIf modules.programs.claude-code.enable {
      programs.claude-code.skills = skills;
    })

    (lib.mkIf modules.programs.codex.enable {
      programs.codex.skills = skills;
    })

    (lib.mkIf modules.programs.opencode.enable {
      programs.opencode.skills = skills;
    })
  ];
}
