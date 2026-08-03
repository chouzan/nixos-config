{
  config,
  inputs,
  lib,
  ...
}:

let
  inherit (config) modules;

  cfg = modules.programs.llm-plugins.caveman;
  caveman = inputs.llm-caveman;
  codexHooks = (lib.importJSON "${caveman}/.codex/hooks.json").hooks;
in
{
  config = lib.mkMerge [
    (lib.mkIf (cfg.enable && modules.programs.claude-code.enable) {
      modules.programs.claude-code.userSettings.statusLine = {
        type = "command";
        command = "bash \"${caveman}/src/hooks/caveman-statusline.sh\"";
      };
    })

    (lib.mkIf (cfg.enable && modules.programs.codex.enable) {
      modules.programs.codex.systemSettings = {
        features.hooks = true;
        hooks = codexHooks;
      };
    })
  ];
}
