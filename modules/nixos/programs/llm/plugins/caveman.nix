{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

let
  inherit (config) modules;

  cfg = modules.programs.llm.plugins.caveman;
  caveman = inputs.llm-caveman;
  codexHooks = (lib.importJSON "${caveman}/.codex/hooks.json").hooks;
in
{
  config = lib.mkMerge [
    (lib.mkIf (cfg.enable && modules.programs.llm.claude-code.enable) {
      # The badge is the last segment, so the model and the effort level read
      # first. The status line itself is composed by the claude-code module.
      modules.programs.llm.claude-code.statusLineSegments = [
        {
          order = 90;
          command = "${lib.getExe pkgs.bash} ${caveman}/src/hooks/caveman-statusline.sh";
        }
      ];
    })

    (lib.mkIf (cfg.enable && modules.programs.llm.codex.enable) {
      modules.programs.llm.codex.systemSettings = {
        features.hooks = true;
        hooks = codexHooks;
      };
    })
  ];
}
