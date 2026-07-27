{ lib, ... }:

let
  inherit (lib) types;

  windowRuleDescription = ''
    Each rule is an attribute set rendered as an `hl.window_rule({ ... })` call:
    - `name`: Rule identifier (for debugging)
    - `match`: Attribute set of match conditions (e.g. `class`, `title`,
      `xwayland`, `workspace`)
    - Remaining keys are rule actions (e.g. `float`, `size`, `workspace`,
      `opacity`, `pin`, `suppress_event`)

    See <https://wiki.hypr.land/Configuring/Basics/Window-Rules/> for the full set of
    match conditions and actions. Rules evaluate top to bottom; order matters.
  '';

  windowRuleExample = [
    {
      name = "steam";
      match.class = "steam";
      float = true;
    }

    {
      name = "firefox-pip";

      match = {
        class = "firefox";
        title = "Picture-in-Picture";
      };

      float = true;
      pin = true;
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
