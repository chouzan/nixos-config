{ osConfig, lib, ... }:

let
  inherit (osConfig) modules;

  cfg = modules.programs.jujutsu;

  red = {
    fg = "red";
  };

  dimGreen = {
    fg = "green";
    dim = true;
  };

  yellow = {
    fg = "yellow";
  };

  dimBlue = {
    fg = "blue";
    dim = true;
  };

  dimCyan = {
    fg = "cyan";
    dim = true;
  };

  logTemplate = ''
    label(
      separate(" ",
        if(current_working_copy, "working_copy"),
        if(immutable, "immutable", "mutable"),
        if(conflict, "conflicted"),
      ),
      separate(" ",
        change_id.shortest(7),
        if(empty, empty_commit_marker),
        if(description,
          description.first_line(),
          label(if(empty, "empty"), description_placeholder),
        ),
        label("log-ref", surround("(", ")", bookmarks)),
        commit_id.shortest(7),
        label("log-time", "(" ++ committer.timestamp().ago() ++ ")"),
        label("log-signature", "<" ++ author.name() ++ ">"),
      ),
    ) ++
    "\n"
  '';
in
{
  config = lib.mkIf cfg.enable {
    programs.jujutsu.settings = {
      colors = {
        "change_id shortest prefix" = yellow;
        "commit_id shortest prefix" = dimGreen;
        "log-ref" = red;
        "log-ref bookmarks" = red;
        "log-signature" = dimBlue;
        "log-signature author" = dimBlue;
        "log-time" = dimCyan;
        "log-time timestamp" = dimCyan;
      };

      aliases = rec {
        # -- Status --------------------------------------------------------------

        st = [ "status" ];

        # -- Show ----------------------------------------------------------------

        so = [ "show" ];

        # -- Diff ----------------------------------------------------------------

        di = [ "diff" ];

        # -- Log -----------------------------------------------------------------

        lo = [
          "log"
          "--template"
          logTemplate
        ];

        loa = lo ++ [
          "--revisions"
          "::"
        ];

        # Log without graph or pager; colored for piping
        lonc = lo ++ [
          "--no-graph"
          "--no-pager"
          "--color=always"
        ];

        el = [ "evolog" ];

        # -- Change --------------------------------------------------------------

        ne = [ "new" ];

        ed = [ "edit" ];

        dc = [ "describe" ];
        dcm = dc ++ [ "--message" ];

        rt = [ "restore" ];

        # -- Operation -----------------------------------------------------------

        ud = [ "undo" ];

        # -- Bookmark ------------------------------------------------------------

        bm = [ "bookmark" ];
        bml = bm ++ [ "list" ];

        bmt = bm ++ [
          "track"
          "--remote=origin"
        ];

        # -- Split ---------------------------------------------------------------

        sp = [ "split" ];

        # -- Squash --------------------------------------------------------------

        sq = [ "squash" ];
        sqt = sq ++ [ "--to" ];

        # -- Rebase --------------------------------------------------------------

        rb = [ "rebase" ];
        rbo = rb ++ [ "--onto" ];

        # -- Remote --------------------------------------------------------------

        fe = [
          "git"
          "fetch"
        ];

        ps = [
          "git"
          "push"
        ];

        psb = ps ++ [
          "--bookmark"
        ];
      };
    };
  };
}
