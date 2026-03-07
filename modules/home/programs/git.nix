# TODO: Make git GPG sign settings configurable

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

          core.hooksPath = "${config.xdg.configHome}/git/hooks";

          alias = {
            st = "status";
            stsb = "st --short --branch";
            stu = "st --untracked-files=no";
            sti = "st --ignored";
            sts = "st --show-stash";
            stv = "st --verbose";
            stvv = "st -vv";

            sw = "show";

            di = "diff";
            dit = "di --stat";
            dif = "di --function-context";
            dic = "di --color-moved=dimmed-zebra";
            dig = "di --staged";
            digt = "dig --stat";
            digf = "dig --function-context";
            digc = "dig --color-moved=dimmed-zebra";
            dih = "di HEAD";
            diuh = "di @{upstream}...HEAD";

            lo = "log --graph --pretty=format:'%C(yellow)%h%Creset%C(auto)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset'";
            lonc = "!git --no-pager lo --no-graph --color=always";
            loht = "log -1 HEAD --stat";

            ad = "add";
            ada = "ad --all";

            sh = "stash";
            shp = "sh pop";
            shl = "sh list";
            shs = "sh show";
            shd = "sh drop";

            cm = "commit";
            cmm = "cm --message";
            cmf = "cm --fixup";
            cman = "cm --amend --no-edit";

            rs = "reset";
            rsh = "rs HEAD --";

            br = "branch";
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
            grc = "!git rev-list --all | xargs git grep -F";
          }
          // lib.optionalAttrs modules.programs.fzf.enable {
            fzsw = "!f() { line=$(git lonc | fzf --ansi --no-sort) || exit; set -- $line; git sw $1; }; f";
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
        if git diff --cached --diff-filter=ACM | grep -qE '^[+].*(<<<<<<|======|>>>>>>)'; then
          echo "Error: Conflict markers found in staged files"
          exit 1
        fi
      '';

      executable = true;
    };
  };
}
