# TODO: Make git GPG sign settings configurable
# Add %G? to --pretty=format for GPG signature status

{
  osConfig,
  config,
  lib,
  pkgs,
  machine,
  ...
}:

let
  inherit (osConfig) modules;
  inherit (machine) user;

  cfg = modules.programs.git;
in
{
  imports = [
    ./aliases.nix
    ./hooks
  ];

  config = lib.mkIf cfg.enable {
    programs = {
      git = {
        enable = true;

        settings = {
          user = {
            inherit (user) name;
            email = user.gitEmail;
          };

          init.defaultBranch = "master";
          checkout.defaultRemote = "origin";
          branch.sort = "-committerdate";
          pager.branch = false;

          tag = {
            sort = "-version:refname";

            # NOTE: Uncomment for signed tags
            # gpgSign = true;
          };

          # NOTE: Uncomment for signed commits
          # commit.gpgSign = true;

          fetch.prune = true;

          pull.rebase = true;

          push = {
            autoSetupRemote = true;
            useForceIfIncludes = true;

            # NOTE: Uncomment for signed pushes
            # gpgSign = true;
          };

          diff.algorithm = "histogram";
          merge.conflictStyle = "zdiff3";

          rebase = {
            autoStash = true;
            autoSquash = true;
            updateRefs = true;
          };

          rerere.enabled = true;
          help.autoCorrect = "prompt";

          core = {
            autocrlf = "input";
            hooksPath = "${config.xdg.configHome}/git/hooks";
            whitespace = "tab-in-indent,incomplete-line";
          };

          url = {
            "git@github.com:".insteadOf = "gh:";
            "git@gitlab.com:".insteadOf = "gl:";
          };
        };
      };

      delta = {
        enable = true;
        enableGitIntegration = true;

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

      ssh = {
        enable = true;
        enableDefaultConfig = false;

        settings = {
          "github.com" = {
            HostName = "github.com";
            User = "git";
            IdentityFile = "~/.ssh/id_ed25519";
            AddKeysToAgent = "confirm";
          };

          "gitlab.com" = {
            HostName = "gitlab.com";
            User = "git";
            IdentityFile = "~/.ssh/id_ed25519";
            AddKeysToAgent = "confirm";
          };
        };
      };

      gpg.enable = true;
    };

    services.gpg-agent = {
      enable = true;
      enableSshSupport = true;
      enableZshIntegration = modules.programs.zsh.enable;
      pinentry.package = pkgs.pinentry-rofi;
    };
  };
}
