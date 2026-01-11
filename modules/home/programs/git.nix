# TODO: Make git GPG sign settings configurable

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

          alias = {
            st = "status";
            ss = "st --short --branch";
            su = "st --untracked-files=no";
            si = "st --ignored";
            sh = "st --show-stash";
            sv = "st --verbose";
            svv = "st -vv";

            di = "diff";
            dx = "di --stat";
            df = "di --function-context";
            dz = "di --color-moved=dimmed-zebra";
            ds = "di --staged";
            dsx = "dx --staged";
            dsf = "df --staged";
            dsz = "dz --staged";
            da = "di HEAD";
            dup = "di @{upstream}...HEAD";

            lo = "log --graph --pretty=format:'%C(yellow)%h%Creset%C(auto)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset'";
            lop = "!git --no-pager lo --no-graph --color=always";
            lh = "log -1 HEAD --stat";

            ch = "checkout";

            br = "branch";

            ad = "add";
            aa = "add --all";

            xx = "reset HEAD --";

            co = "commit";
            cm = "co --message";
            cf = "co --fixup";
            ca = "co --amend --no-edit";

            eb = "rebase";
            ei = "eb --interactive";
            es = "ei --autosquash";

            re = "remote";
            rv = "remote --verbose";

            # Fixup and autosquash
            cfes = "!f() { git cf \"$1\" && git es \"$1\"^; }; f";

            # Search for a string across all commit messages output
            grm = "!f() { git lo --color=always | grep --ignore-case \"$1\" --context=2 --color=always; }; f";

            # Search for a string across all commits in the repository
            gri = "!git rev-list --all | xargs git grep -F";
          }
          // lib.optionalAttrs modules.programs.fzf.enable {
            fzow = "!f() { line=$(git lop | fzf --ansi --no-sort) || exit; set -- $line; git show $1; }; f";
            fzcfes = "!f() { line=$(git lop --max-count=35 | fzf --ansi --no-sort) || exit; set -- $line; git cfes $1; }; f";
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
  };
}
