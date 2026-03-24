{ osConfig, lib, ... }:

let
  cfg = osConfig.modules.programs.zed;

  bind =
    key: pairs:
    map (pair: {
      inherit (pair) context;
      bindings.${key} = pair.action;
    }) pairs;

  context = ctx: action: {
    inherit action;
    context = ctx;
  };

  bindTerminal =
    key: action:
    bind key [
      (context "Terminal" action)
    ];

  bindNormal =
    key: action:
    bind key [
      (context "(Dock && !Terminal) || (Editor && vim_mode == normal)" action)
    ];
in
{
  config = lib.mkIf cfg.enable {
    programs.zed-editor = {
      userKeymaps = lib.flatten [
        # -- Ctrl Keys ---------------------------------------------------------

        (bind "ctrl-t" [
          (context "Editor" "workspace::NewFile")
          (context "Terminal" "workspace::NewTerminal")
        ])

        (bind "ctrl-w" [
          (context "Dock" "workspace::CloseActiveDock")
          (context "Pane" "pane::CloseActiveItem")
        ])

        # -- Terminal Keys -----------------------------------------------------

        (bindTerminal "ctrl-space" null)

        (bindTerminal "ctrl-space f h" "workspace::ActivatePaneLeft")
        (bindTerminal "ctrl-space f j" "workspace::ActivatePaneDown")
        (bindTerminal "ctrl-space f k" "workspace::ActivatePaneUp")
        (bindTerminal "ctrl-space f l" "workspace::ActivatePaneRight")

        (bindTerminal "ctrl-space f e" "editor::ToggleFocus")

        (bindTerminal "ctrl-space p n" "workspace::NewTerminal")
        (bindTerminal "ctrl-space p w" "pane::CloseActiveItem")

        # -- Space Keys --------------------------------------------------------

        (bindNormal "space" null)

        # -- Space-F (Focus) ---------------------------------------------------

        (bindNormal "space f h" "workspace::ActivatePaneLeft")
        (bindNormal "space f j" "workspace::ActivatePaneDown")
        (bindNormal "space f k" "workspace::ActivatePaneUp")
        (bindNormal "space f l" "workspace::ActivatePaneRight")

        (bindNormal "space f p" "project_panel::ToggleFocus")
        (bindNormal "space f o" "outline_panel::ToggleFocus")

        (bindNormal "space f d" "debug_panel::ToggleFocus")
        (bindNormal "space f g" "git_panel::ToggleFocus")
        (bindNormal "space f a" "agent::ToggleFocus")

        (bindNormal "space f e" "editor::ToggleFocus")
        (bindNormal "space f t" "terminal_panel::ToggleFocus")

        # -- Space-T (Toggle) --------------------------------------------------

        (bindNormal "space t p" "project_panel::Toggle")
        (bindNormal "space t o" "outline_panel::Toggle")

        (bindNormal "space t d" "debug_panel::Toggle")
        (bindNormal "space t g" "git_panel::Toggle")
        (bindNormal "space t a" "agent::Toggle")

        (bindNormal "space t t" "terminal_panel::Toggle")

        # -- Space-P (Panel and Pane) ------------------------------------------

        (bindNormal "space p n" "workspace::NewFile")

        (bind "space p w" [
          (context "Dock && !Terminal" "workspace::CloseActiveDock")
          (context "Editor && vim_mode == normal" "pane::CloseActiveItem")
        ])

        (bindNormal "space p f n" "workspace::NewFile")
        (bindNormal "space p f c" "project_panel::Duplicate")
        (bindNormal "space p f r" "project_panel::Rename")
        (bindNormal "space p f d" "project_panel::Delete")

        (bindNormal "space p s h" "pane::SplitLeft")
        (bindNormal "space p s j" "pane::SplitDown")
        (bindNormal "space p s k" "pane::SplitUp")
        (bindNormal "space p s l" "pane::SplitRight")

        # -- Space-E (Editor) --------------------------------------------------

        (bindNormal "space e s s" "workspace::Save")
        (bindNormal "space e s a" "workspace::SaveAll")

        # -- Space-G (Git) -----------------------------------------------------

        (bindNormal "space g t b" "git::Blame")

        (bindNormal "space g d" "git::Diff")

        (bindNormal "space g a t" "git::ToggleStaged")
        (bindNormal "space g a n" "git::StageAndNext")
        (bindNormal "space g a a" "git::StageAll")

        (bindNormal "space g r r" "git::Restore")
        (bindNormal "space g r f" "git::RestoreFile")
        (bindNormal "space g r n" "git::UnstageAndNext")
        (bindNormal "space g r a" "git::UnstageAll")
      ];
    };
  };
}
