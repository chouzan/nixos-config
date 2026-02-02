{
  osConfig,
  config,
  lib,
  ...
}:

let
  inherit (config.xdg) userDirs;
  cfg = osConfig.modules.desktop.hyprland;
in
{
  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland.settings = {
      "$mainMod" = "SUPER";
      "$ctrlMod" = "$mainMod CTRL";
      "$altMod" = "$mainMod ALT";
      "$shiftMod" = "$mainMod SHIFT";
      "$altCtrlMod" = "$ctrlMod ALT";
      "$shiftCtrlMod" = "$ctrlMod SHIFT";
      "$shiftAltMod" = "$altMod SHIFT";
      "$hyperMod" = "$mainMod CTRL ALT SHIFT";

      # Bind flags
      # c  Click             Will trigger on release of a key or button as long as the mouse cursor stays inside `binds:drag_threshold`
      # d  Has description   Will allow you to write a description for your bind
      # e  Repeat            Will repeat when held
      # g  Drag              Will trigger on release of a key or button as long as the mouse cursor moves outside `binds:drag_threshold`
      # i  Ignore mods       Will ignore modifiers
      # l  Locked            Will also work when an input inhibitor (e.g. a lockscreen) is active
      # m  Mouse             See the dedicated [Mouse Binds](https://wiki.hypr.land/Configuring/Binds/#mouse-binds)
      # n  Non-consuming     Key/mouse events will be passed to the active window in addition to triggering the dispatcher
      # o  LongPress         Will trigger on long press of a key
      # p  Bypass            Bypasses the app's requests to inhibit keybinds
      # r  Release           Will trigger on release of a key
      # s  Separate          Will arbitrarily combine keys between each mod/key, see [Keysym Combos](https://wiki.hypr.land/Configuring/Binds/#keysym-combos)
      # t  Transparent       Cannot be shadowed by other binds
      # u  Submap universal  Will be active no matter the submap

      bind = lib.mkMerge [
        [
          "$hyperMod, Q, exit,"
          "$mainMod, L, exec, hyprlock"

          "$mainMod, W, killactive,"
          "$mainMod, Q, forcekillactive,"

          "$mainMod, A, exec, $menu"
          "$mainMod, E, exec, $fileManager"
          "$mainMod, T, exec, $terminal"
          "$mainMod, D, exec, $editor"
          "$mainMod, I, exec, $ai"
          "$mainMod, B, exec, $webBrowser"
          "$mainMod, U, exec, $musicPlayer"

          ''
            , Print, exec, grim -g "$(slurp -doc '##ff0000ff')" -t png -\
            | satty --filename - --output-filename ${userDirs.pictures}/Screenshot/$(date '+%Y%m%d%H%M%S')_screenshot.png
          ''
          ''
            ALT, Print, exec, grim -g "$(hyprctl monitors -j | jq -r '.[] | select(.focused) | [.] | if length != 1 then error("expected exactly one focused monitor") else .[0] end | "\(.x),\(.y) \(.width)x\(.height)"')" -t png -\
            | satty --filename - --output-filename ${userDirs.pictures}/Screenshot/$(date '+%Y%m%d%H%M%S')_screenshot.png
          ''
          ''
            CTRL, Print, exec, grim -g "$(hyprctl activewindow -j | jq -r '. | "\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')" -t png -\
            | satty --filename - --output-filename ${userDirs.pictures}/Screenshot/$(date '+%Y%m%d%H%M%S')_screenshot.png
          ''

          "$mainMod, RETURN, fullscreen, 1"
          "$altMod, RETURN, fullscreen, 0"

          "$mainMod, F, togglefloating, active"

          "$mainMod, left, movefocus, l"
          "$mainMod, down, movefocus, d"
          "$mainMod, up, movefocus, u"
          "$mainMod, right, movefocus, r"

          #########################
          # Switch workspace to

          "$shiftAltMod, 1, workspace, name:primary"
          "$shiftAltMod, 2, workspace, name:auxiliary"
          "$shiftAltMod, 3, workspace, name:other"
          # "$shiftAltMod, 1, workspace, 1"
          # "$shiftAltMod, 2, workspace, 2"
          # "$shiftAltMod, 3, workspace, 3"

          # Switch workspace to end
          #########################

          ####################
          # Move window to

          "$shiftCtrlMod, 1, movetoworkspace, name:primary"
          "$shiftCtrlMod, 2, movetoworkspace, name:auxiliary"
          "$shiftCtrlMod, 3, movetoworkspace, name:other"
          # "$shiftCtrlMod, 1, movetoworkspace, 1"
          # "$shiftCtrlMod, 2, movetoworkspace, 2"
          # "$shiftCtrlMod, 3, movetoworkspace, 3"

          # Move window to end
          ####################

          ########################
          # Special workspace

          "$mainMod, S, togglespecialworkspace, terminal"
          "$shiftCtrlMod, S, movetoworkspace, special:terminal"

          # Special workspaces end
          ########################

          # Scroll through existing workspaces with mainMod + scroll
          # "$mainMod, mouse_down, workspace, e+1"
          # "$mainMod, mouse_up, workspace, e-1"

          #########################
          # Master layout binds

          "$ctrlMod, RETURN, layoutmsg, focusmaster master"

          "$shiftMod, RETURN, layoutmsg, swapwithmaster master"

          "$altMod, H, layoutmsg, orientationleft"
          "$altMod, J, layoutmsg, orientationcenter"
          "$altMod, SPACE, layoutmsg, orientationcycle left center"

          "$altMod, 1, layoutmsg, mfact exact 0.382" # Inverse golden ratio
          "$altMod, 2, layoutmsg, mfact exact 0.414" # Silver ratio
          "$altMod, 3, layoutmsg, mfact exact 0.45" # More usable sides
          "$altMod, 4, layoutmsg, mfact exact 0.55" # Simple 50/50
          "$altMod, 5, layoutmsg, mfact exact 0.618" # Golden ratio

          # Master layout binds end
          #########################

          ##########################
          # Dwindle layout binds

          "$mainMod, P, pseudo,"

          "$altMod, J, layoutmsg, togglesplit"
          "$altMod, K, layoutmsg, togglesplit"

          # Dwindle layout binds end
          ##########################
        ]

        # Clipboard manager
        (lib.mkIf config.services.clipse.enable [
          "$mainMod, V, exec, $terminal --class clipse --execute clipse"
        ])
      ];

      bindl = [
        ", XF86AudioPlay, exec, playerctl --player=spotify,%any play-pause"
        ", XF86AudioPause, exec, playerctl --player=spotify,%any play-pause"
        ", XF86AudioStop, exec, playerctl --all-players stop"

        ", XF86AudioNext, exec, playerctl --player=spotify,%any next"
        ", XF86AudioPrev, exec, playerctl --player=spotify,%any previous"

        ", XF86AudioForward, exec, playerctl --player=spotify,%any position 5+"
        ", XF86AudioRewind, exec, playerctl --player=spotify,%any position 5-"

        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"

        ", XF86PowerOff, exec, systemctl suspend"
      ];

      bindel = [
        ", XF86AudioRaiseVolume, exec, wpctl set-volume --limit=1.0 @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"

        ", XF86MonBrightnessUp, exec, brightnessctl set 5%+"
        ", XF86MonBrightnessDown, exec, brightnessctl --min-value=3 set 5%-"
      ];

      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];
    };
  };
}
