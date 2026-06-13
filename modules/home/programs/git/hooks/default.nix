{ osConfig, lib, ... }:

let
  cfg = osConfig.modules.programs.git;
in
{
  config = lib.mkIf cfg.enable {
    xdg.configFile."git/hooks/pre-commit" = {
      text = ''
        #!/usr/bin/env bash
        if ! git diff --cached --check 2>/dev/null; then
          echo "error: conflict markers found in staged files"
          exit 1
        fi

        repo_hook="$(git rev-parse --show-toplevel 2>/dev/null)/.githooks/pre-commit"
        [ -x "$repo_hook" ] && exec "$repo_hook"
        exit 0
      '';

      executable = true;
    };
  };
}
