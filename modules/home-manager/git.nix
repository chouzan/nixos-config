{ pkgs, ... }:

{
  config = {
    programs = {
      git = {
        enable = true;
        userName = "Muhammad Fauzan";
        userEmail = "mfauzanmhf@gmail.com";

        extraConfig = {
          init.defaultBranch = "master";
          push.autoSetupRemote = true;

          # Better commit experience
          commit.gpgsign = false; # Set to true if you want signed commits

          diff.algorithm = "histogram";
          merge.conflictStyle = "diff3";

          url."git@github.com:".insteadOf = "gh:";
          url."git@gitlab.com:".insteadOf = "gl:";
        };

        aliases = {
          st = "status";
          ch = "checkout";
          br = "branch";
          ad = "add";
          aa = "add --all";
          di = "diff";
          co = "commit";
          cm = "commit -m";
          ca = "commit --amend --no-edit";
          un = "reset HEAD --";
          rv = "remote -v";
          lo = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
          se = "!git rev-list --all | xargs git grep -F";
          last = "log -1 HEAD --stat";
        };

        delta = {
          enable = true;

          options = {
            line-numbers = true;
            side-by-side = true;
            dark = true;
          };
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
      enableZshIntegration = true;
      pinentry.package = pkgs.pinentry-rofi;
    };
  };
}
