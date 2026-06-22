{ osConfig, lib, ... }:

let
  cfg = osConfig.modules.programs.git;
in
{
  config = lib.mkIf cfg.enable {
    xdg.configFile."git/hooks/pre-commit" = {
      text = ''
        #!/usr/bin/env bash

        git diff --cached --check || exit 1

        repo_hook="$(git rev-parse --show-toplevel 2>/dev/null)/.githooks/pre-commit"
        [ -x "$repo_hook" ] && exec "$repo_hook"

        exit 0
      '';

      executable = true;
    };
  };
}
