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

          alias = {
            st = "status";
            stsb = "st --short --branch";
            stu = "st --untracked-files=no";
            sti = "st --ignored";
            sts = "st --show-stash";
            stv = "st --verbose";
            stvv = "st -vv";

            so = "show";

            sw = "switch";
            swc = "sw --create";

            di = "diff";
            dit = "di --stat";
            dif = "di --function-context";
            dic = "di --color-moved=dimmed-zebra";
            din = "di --name-only";
            dis = "di --staged";
            dist = "dis --stat";
            disf = "dis --function-context";
            disc = "dis --color-moved=dimmed-zebra";
            dih = "di HEAD";
            diuh = "di @{upstream}...HEAD";

            lo = "log --graph --pretty=format:'%C(auto)%h%C(reset)%C(auto)%d%C(reset) %s %C(dim cyan)(%cr)%C(reset) %C(dim blue)<%an>%C(reset)'";
            loa = "lo --all";
            lonc = "!git --no-pager lo --no-graph --color=always";
            loht = "log -1 HEAD --stat";

            ad = "add";
            adp = "ad --patch";
            ada = "ad --all";

            sh = "stash";
            shl = "sh list";
            shs = "sh show";
            shp = "sh pop";
            sha = "sh apply";
            shd = "sh drop";

            cm = "commit";
            cmm = "cm --message";
            cmf = "cm --fixup";
            cma = "cm --amend";
            cman = "cma --no-edit";

            rs = "reset";
            rsf = "rs HEAD --";
            rsh = "rs --soft HEAD^";

            br = "branch";
            bra = "br --all";
            brd = "br --delete";
            brdf = "brd --force";

            co = "checkout";

            rb = "rebase";
            rbi = "rb --interactive";
            rbin = "rbi --no-autosquash";
            rbc = "rb --continue";
            rbs = "rb --skip";
            rba = "rb --abort";

            arbi = "!GIT_SEQUENCE_EDITOR=: git rbi";

            me = "merge";

            ro = "remote";
            rov = "ro --verbose";

            fe = "fetch";

            pl = "pull";

            ps = "push";
            psf = "ps --force-with-lease";

            # Fixup and autosquash
            cmfrbi = "!f() { git cmf \"$1\" && git rbi \"$1\"^; }; f";

            # Search for a string across all commit messages output
            grm = "!f() { git lo --color=always | grep --ignore-case \"$1\" --context=2 --color=always; }; f";

            # Search for a string across all commits in the repository
            grc = "!git rev-list --all | xargs git grep --fixed-strings";

            wip = "cm --all --message 'WIP' --no-verify";
            cleanup = "!git branch --merged | grep --extended-regexp --invert-match '\\*|master|main|develop' | xargs -n 1 git branch -d";
          }
          // lib.optionalAttrs modules.programs.fzf.enable {
            fzso = "!f() { line=$(git lonc | fzf --ansi --no-sort) || exit; set -- $line; git so $1; }; f";
            fzcmfrbi = "!f() { line=$(git lonc --max-count=35 | fzf --ansi --no-sort) || exit; set -- $line; git cmfrbi $1; }; f";
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

    xdg.configFile."git/hooks/pre-commit" = {
      text = ''
        #!/usr/bin/env sh
        if git diff --cached --diff-filter=ACM | grep --extended-regexp --quiet '^[+].*(<<<<<<|======|>>>>>>)'; then
          echo "Error: Conflict markers found in staged files"
          exit 1
        fi
      '';

      executable = true;
    };
  };
}
