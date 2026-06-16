{ osConfig, lib, ... }:

let
  inherit (osConfig) modules;

  cfg = modules.programs.git;
in
{
  config = lib.mkIf cfg.enable {
    programs.git.settings.alias = {
      # -- Status --------------------------------------------------------------

      st = "status";
      stsb = "st --short --branch";
      stu = "st --untracked-files=no";
      sti = "st --ignored";
      sts = "st --show-stash";
      stv = "st --verbose";
      stvv = "st --verbose --verbose";

      # -- Show ----------------------------------------------------------------

      so = "show";

      # -- Diff ----------------------------------------------------------------

      di = "diff";
      dit = "di --stat";
      dif = "di --function-context";
      din = "di --name-only";
      dis = "di --staged";
      dist = "dis --stat";
      disf = "dis --function-context";
      dih = "di HEAD";
      diuh = "di @{upstream}...HEAD";

      # -- Log -----------------------------------------------------------------

      lo = "log --graph --pretty=format:'%C(auto)%h%C(reset)%C(auto)%d%C(reset) %s %C(dim cyan)(%cr)%C(reset) %C(dim blue)<%an>%C(reset)'";
      loa = "lo --all";

      # Log without graph or pager; colored for piping
      lonc = "!git --no-pager lo --no-graph --color=always";

      loht = "log --max-count=1 HEAD --stat";

      # -- Switch --------------------------------------------------------------

      sw = "switch";
      swc = "sw --create";

      # -- Add -----------------------------------------------------------------

      ad = "add";
      adp = "ad --patch";
      ada = "ad --all";

      # -- Stash ---------------------------------------------------------------

      sh = "stash";
      shl = "sh list";
      shs = "sh show";
      shp = "sh pop";
      sha = "sh apply";
      shd = "sh drop";

      # -- Commit --------------------------------------------------------------

      cm = "commit";
      cmm = "cm --message";
      cmf = "cm --fixup";
      cma = "cm --amend";
      cman = "cma --no-edit";

      # -- Restore -------------------------------------------------------------

      rt = "restore";
      rts = "rt --staged";

      # -- Reset ---------------------------------------------------------------

      rs = "reset";
      rss = "rs --soft HEAD^";
      rsf = "rs --hard";

      # -- Branch --------------------------------------------------------------

      br = "branch";

      # List branches excluding current; cleaned for piping
      brl = "!git br | grep --invert-match '^[*]' | sed 's/^  //'";

      bra = "br --all";
      brd = "br --delete";
      brdf = "brd --force";

      # -- Checkout ------------------------------------------------------------

      co = "checkout";

      # -- Rebase --------------------------------------------------------------

      rb = "rebase";
      rbi = "rb --interactive";
      rbin = "rbi --no-autosquash";
      rbc = "rb --continue";
      rbs = "rb --skip";
      rba = "rb --abort";

      # Auto-accept rebase sequence; skips editor
      arbi = "!GIT_SEQUENCE_EDITOR=: git rbi";

      # -- Merge ---------------------------------------------------------------

      me = "merge";

      # -- Remote --------------------------------------------------------------

      ro = "remote";
      rov = "ro --verbose";

      fe = "fetch";

      pl = "pull";

      ps = "push";
      psf = "ps --force-with-lease";

      # -- Compound ------------------------------------------------------------

      # Create fixup commit and autosquash rebase onto target
      cmfrbi = "!f() { git cmf \"$1\" && git rbi \"$1\"^; }; f";

      # Search commit messages for a string
      grm = "!f() { git lo --color=always | grep --ignore-case --color=always --context=2 \"$1\"; }; f";

      # Search all commits for a string in file contents
      grc = "!git rev-list --all | xargs git grep --fixed-strings";

      # Stage all and commit as WIP; skips hooks
      wip = "cm --all --message='WIP' --no-verify";

      # Delete all merged branches except main/master/develop
      cleanup = "!git br --merged | grep --extended-regexp --invert-match '\\*|master|main|develop' | xargs --max-args=1 git brd";
    }
    // lib.optionalAttrs modules.programs.fzf.enable {
      # -- Fzf pickers ---------------------------------------------------------

      # Pick a commit from log; runs action or prints hash
      fzloref = "!f() { action=$1; shift; line=$(git lonc \"$@\" | fzf --ansi --no-sort) || return; set -- $line; if [ -z \"$action\" ]; then echo $1; else git $action $1; fi; }; f";

      fzso = "fzloref so";
      # Pick a commit to interactively rebase onto; includes the selected commit
      fzrbi = "!f() { ref=$(git fzloref) || return; git rbi $ref^; }; f";
      fzcmfrbi = "fzloref cmfrbi --max-count=35";

      # Pick branch with log preview; prints name if no action is given
      fzbrref = "!f() { action=$1; shift; sel=$(git brl | fzf \"$@\" --preview-window=wrap --preview='git lo --max-count=10 --color=always {}') || return; if [ -z \"$action\" ]; then echo \"$sel\"; else echo \"$sel\" | xargs git $action; fi; }; f";

      fzsw = "fzbrref sw";
      fzbrd = "fzbrref brd --multi";
      fzbrdf = "fzbrref brdf --multi";

      # Pick stash with diff preview; outputs the stash ref
      fzshref = "!f() { stash=$(git shl | fzf --no-sort --preview-window=wrap --preview='git shs --color=always $(echo {} | cut --delimiter=: --fields=1)') || return; echo \"$stash\" | cut --delimiter=: --fields=1; }; f";

      # Pick stash and run action; defaults to show
      fzsh = "!f() { ref=$(git fzshref) || return; git sh \${@:-show} $ref; }; f";

      fzsha = "fzsh apply";
      fzshp = "fzsh pop";
      fzshd = "fzsh drop";

      # Pick modified/untracked files to stage
      fzad = "!f() { files=$(git ls-files --modified --others --exclude-standard | fzf --multi --preview-window=wrap --preview='git di --color=always -- {} 2>/dev/null || cat {}') || return; echo \"$files\" | xargs git ad; }; f";

      # Pick modified files to restore; discards changes
      fzrt = "!f() { files=$(git di --name-only | fzf --multi --preview-window=wrap --preview='git di --color=always -- {}') || return; echo \"$files\" | xargs git rt; }; f";

      # Pick staged files to unstage
      fzrts = "!f() { files=$(git dis --name-only | fzf --multi --preview-window=wrap --preview='git dis --color=always -- {}') || return; echo \"$files\" | xargs git rts; }; f";
    };
  };
}
