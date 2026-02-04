{
  osConfig,
  lib,
  pkgs,
  ...
}:

let
  cfg = osConfig.modules.desktop.hyprland;

  hyprctl = "${pkgs.hyprland}/bin/hyprctl";
  jq = "${pkgs.jq}/bin/jq";
  socat = "${pkgs.socat}/bin/socat";

  hypr-auto-mfact = pkgs.writeShellScript "hypr-auto-mfact" ''
    set -euo pipefail

    get_mfact_for_window_count() {
      case $1 in
        0|1) echo "" ;;
        2|3) echo "0.55" ;;
        *)   echo "0.45" ;;
      esac
    }

    is_master_layout() {
      [[ $(${hyprctl} getoption general:layout -j | ${jq} -r '.str') == "master" ]]
    }

    get_active_workspace_name() {
      local special_ws
      special_ws=$(${hyprctl} monitors -j | ${jq} -r '.[] | select(.focused) | .specialWorkspace | select(.id != 0) | .name')

      if [[ -n "$special_ws" ]]; then
        echo "$special_ws"
      else
        ${hyprctl} activeworkspace -j | ${jq} -r '.name'
      fi
    }

    get_workspace_window_count() {
      local workspace_name=$1
      ${hyprctl} workspaces -j | ${jq} -r --arg name "$workspace_name" '.[] | select(.name == $name) | .windows'
    }

    update_mfact_for_active_workspace() {
      local window_count mfact
      window_count=$(get_workspace_window_count "$(get_active_workspace_name)")
      mfact=$(get_mfact_for_window_count "$window_count")

      if [[ -n "$mfact" ]]; then
        ${hyprctl} dispatch layoutmsg mfact exact "$mfact"
      fi
    }

    handle_event() {
      is_master_layout || return 0
      sleep 0.05

      case $1 in
        workspace">>"*|focusedmon">>"*|activespecial">>"*|openwindow">>"*|closewindow">>"*|movewindow">>"*|changefloatingmode">>"*)
          update_mfact_for_active_workspace
          ;;
      esac
    }

    if is_master_layout; then
      update_mfact_for_active_workspace
    fi

    ${socat} -U - "UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" \
      | while read -r event; do
          handle_event "$event"
        done
  '';
in
{
  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland.settings.exec-once = [
      "${hypr-auto-mfact}"
    ];
  };
}
