# TODO: Make git GPG sign settings configurable
# Add %G? to --pretty=format for GPG signature status

{
  osConfig,
  config,
  lib,
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
    programs.git = {
      enable = true;

      settings = {
        user = {
          inherit (user) name;
          email = user.gitEmail;
        };

        core = {
          autocrlf = "input";
          hooksPath = "${config.xdg.configHome}/git/hooks";
          whitespace = "tab-in-indent,incomplete-line";
        };

        init.defaultBranch = "master";
        checkout.defaultRemote = "origin";

        diff = {
          algorithm = "histogram";
          colorMoved = "dimmed-zebra";
          mnemonicPrefix = true;
        };

        merge.conflictStyle = "zdiff3";

        commit.verbose = true;

        # NOTE: Uncomment for signed commits
        # commit.gpgSign = true;

        branch.sort = "-committerdate";

        tag = {
          sort = "-version:refname";

          # NOTE: Uncomment for signed tags
          # gpgSign = true;
        };

        fetch = {
          prune = true;
          pruneTags = true;
          fsckObjects = true;
        };

        pull.rebase = true;

        push = {
          autoSetupRemote = true;
          followTags = true;
          useForceIfIncludes = true;

          # NOTE: Uncomment for signed pushes
          # gpgSign = true;
        };

        transfer.fsckObjects = true;
        receive.fsckObjects = true;

        rebase = {
          autoStash = true;
          autoSquash = true;
          updateRefs = true;
          missingCommitsCheck = "error";
        };

        rerere.enabled = true;
        help.autoCorrect = "prompt";
        pager.branch = false;

        url = {
          "git@github.com:".insteadOf = "gh:";
          "git@gitlab.com:".insteadOf = "gl:";
        };
      };
    };
  };
}
