{ osConfig, lib, ... }:

let
  inherit (osConfig) modules;
  cfg = modules.programs.delta;
in
{
  config = lib.mkIf cfg.enable {
    programs.delta = {
      enable = true;

      enableGitIntegration = modules.programs.git.enable;
      enableJujutsuIntegration = modules.programs.jujutsu.enable;

      options = {
        navigate = true;
        line-numbers = true;
        side-by-side = true;
        dark = true;

        hyperlinks = true;
        hyperlinks-file-link-format = "zed://file/{path}:{line}";

        whitespace-error-style = "reverse red";

        syntax-theme = "gruvbox-dark";

        commit-style = "raw";
        commit-decoration-style = "bold yellow box ul";

        file-style = "yellow";
        file-decoration-style = "bold blue box ul";

        hunk-header-style = "file line-number syntax";
        hunk-header-file-style = "cyan";
        hunk-header-line-number-style = "cyan";
        hunk-header-decoration-style = "blue box";

        line-numbers-left-format = "┊{nm:>4}┊";
        line-numbers-right-format = "│{np:>4}│";
        line-numbers-left-style = "blue";
        line-numbers-right-style = "blue";
        line-numbers-minus-style = "red";
        line-numbers-plus-style = "green";
        line-numbers-zero-style = "brightblack";

        # merge-conflict-begin-symbol = "⌃";
        # merge-conflict-end-symbol = "⌄";
        merge-conflict-ours-diff-header-style = "bold yellow";
        merge-conflict-theirs-diff-header-style = "bold yellow";
      };
    };
  };
}
