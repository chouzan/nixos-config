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

          push.autoSetupRemote = true;
          diff.algorithm = "histogram";
          merge.conflictStyle = "zdiff3";

          alias = {
            st = "status";
            di = "diff";
            lo = "log --graph --pretty=format:'%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
            lh = "log -1 HEAD --stat";

            ch = "checkout";
            br = "branch";

            ad = "add";
            aa = "add --all";
            re = "reset HEAD --";

            co = "commit";
            cm = "commit -m";
            ca = "commit --amend --no-edit";

            em = "remote";
            ev = "remote -v";

            # Search for a string across all commits in the repository
            gr = "!git rev-list --all | xargs git grep -F";
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
