{
  osConfig,
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

          # NOTE: Set to true for signed commits
          commit.gpgSign = false;

          # Pull & Push
          push.autoSetupRemote = true;
          pull.rebase = true;

          # Diff & Merge
          diff.algorithm = "histogram";
          merge.conflictStyle = "zdiff3";

          # Rebase
          rebase.autoStash = true;
          rebase.autoSquash = true;

          # Fetch & Prune
          fetch.prune = true;
          fetch.pruneRemotes = true;

          # Remember conflict resolutions
          rerere.enabled = true;

          # Branch sorting
          branch.sort = "-committerdate";
          tag.sort = "-version:refname";

          # Core settings
          core.autocrlf = "input";
          core.whitespace = "trailing-space,space-before-tab";

          # Help
          help.autoCorrect = "prompt";

          alias = {
            # Status & Info
            st = "status -sb";
            s = "status -sb";

            # Diff
            di = "diff";
            dc = "diff --cached";
            ds = "diff --stat";

            # Log
            lo = "log --graph --pretty=format:'%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
            lh = "log -1 HEAD --stat";
            la = "log --graph --all --pretty=format:'%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
            ls = "log --pretty=format:'%C(yellow)%h%Cred%d\\ %Creset%s%Cblue\\ [%cn]' --decorate";

            # Checkout & Branch
            ch = "checkout";
            cb = "checkout -b";
            sw = "switch";
            br = "branch";
            bra = "branch -a";
            brd = "branch -d";
            brD = "branch -D";

            # Add & Reset
            ad = "add";
            aa = "add --all";
            ap = "add --patch";
            re = "reset HEAD --";
            unstage = "reset HEAD --";

            # Commit
            co = "commit";
            cm = "commit -m";
            ca = "commit --amend --no-edit";
            cam = "commit --amend";
            cf = "commit --fixup";

            # Stash
            sl = "stash list";
            ss = "stash save";
            sp = "stash pop";
            sa = "stash apply";

            # Remote
            em = "remote";
            ev = "remote -v";

            # Push & Pull
            ps = "push";
            pl = "pull";
            pf = "push --force-with-lease";

            # Rebase
            rb = "rebase";
            rbi = "rebase -i";
            rbc = "rebase --continue";
            rba = "rebase --abort";

            # Utility
            undo = "reset --soft HEAD^";
            wip = "commit -am 'WIP' --no-verify";
            unwip = "reset HEAD^";

            # Search for a string across all commits in the repository
            gr = "!git rev-list --all | xargs git grep -F";

            # Show changed files
            changed = "diff --name-only";

            # Clean merged branches
            cleanup = "!git branch --merged | grep -v '\\*\\|master\\|main\\|develop' | xargs -n 1 git branch -d";
          };

          url = {
            "git@github.com:".insteadOf = "gh:";
            "git@gitlab.com:".insteadOf = "gl:";
          };
        };
      };

      delta = {
        enable = true;

        options = {
          # Display
          line-numbers = true;
          side-by-side = true;
          dark = true;

          # Navigation
          navigate = true;

          # Syntax highlighting
          syntax-theme = "Dracula";

          # Hyperlinks
          hyperlinks = true;
          hyperlinks-file-link-format = "vscode://file/{path}:{line}";

          # Line numbers styling
          line-numbers-left-format = "{nm:>4}┊";
          line-numbers-right-format = "{np:>4}│";
          line-numbers-left-style = "blue";
          line-numbers-right-style = "blue";
          line-numbers-minus-style = "red";
          line-numbers-plus-style = "green";
          line-numbers-zero-style = "dim white";

          # Commit decoration
          commit-decoration-style = "bold yellow box ul";
          commit-style = "raw";

          # File decoration
          file-style = "bold yellow ul";
          file-decoration-style = "none";

          # Hunk header
          hunk-header-decoration-style = "blue box";
          hunk-header-file-style = "cyan";
          hunk-header-line-number-style = "cyan";
          hunk-header-style = "file line-number syntax";

          # Merge conflicts
          merge-conflict-begin-symbol = "⌃";
          merge-conflict-end-symbol = "⌄";
          merge-conflict-ours-diff-header-style = "yellow bold";
          merge-conflict-theirs-diff-header-style = "yellow bold";

          # Whitespace
          whitespace-error-style = "reverse red";
        };
      };

      ssh = {
        enable = true;
        enableDefaultConfig = false;

        matchBlocks = {
          "github.com" = {
            hostname = "github.com";
            user = "git";
            identityFile = "~/.ssh/id_ed25519";
            addKeysToAgent = "confirm";
          };

          "gitlab.com" = {
            hostname = "gitlab.com";
            user = "git";
            identityFile = "~/.ssh/id_ed25519";
            addKeysToAgent = "confirm";
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
