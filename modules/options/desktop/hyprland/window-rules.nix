{ lib, ... }:

let
  inherit (lib) types;

  windowRuleDescription = ''
    Each rule is an attribute set with:
    - `name`: Rule identifier (for debugging)
    - Match conditions (prefix with `match:`):
      - `match:class` - Window class regex
      - `match:title` - Window title regex
      - `match:initialclass` - Initial class regex
      - `match:initialtitle` - Initial title regex
      - `match:xwayland` - XWayland window (true/false)
      - `match:float` - Floating state (true/false)
      - `match:fullscreen` - Fullscreen state (true/false)
      - `match:pin` - Pinned state (true/false)
      - `match:workspace` - Workspace id or name
    - Actions (without prefix):
      - `float` - "on"/"off"
      - `size` - "width height" or "width% height%"
      - `move` - "x y" or "x% y%"
      - `workspace` - Workspace name/id
      - `opacity` - "active inactive"
      - `pin` - "on"/"off"
      - `stay_focused` - "on"/"off"
      - `no_focus` - "on"/"off"
      - `suppress_event` - Event to suppress (e.g., "maximize")
      - And more: https://wiki.hypr.land/Configuring/Window-Rules/

    Rules are evaluated top to bottom, order matters.
  '';

  windowRuleExample = [
    {
      name = "steam";
      "match:class" = "steam";
      float = "on";
    }
    {
      name = "firefox-pip";
      "match:class" = "firefox";
      "match:title" = "Picture-in-Picture";
      float = "on";
      pin = "on";
      size = "25% 25%";
    }
  ];
in
{
  options.modules.desktop.hyprland = {
    windowRules = lib.mkOption {
      type = types.listOf types.attrs;
      default = [ ];
      example = windowRuleExample;
      description = ''
        Base window rules. Overrides the default rules when set.

        ${windowRuleDescription}
      '';
    };

    extraWindowRules = lib.mkOption {
      type = types.listOf types.attrs;
      default = [ ];
      example = windowRuleExample;
      description = ''
        Additional window rules appended after windowRules.

        ${windowRuleDescription}
      '';
    };
  };
}
