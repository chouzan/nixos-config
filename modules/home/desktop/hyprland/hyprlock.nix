{
  osConfig,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  cfg = osConfig.modules.desktop.hyprland;
  hyprlockPackages = inputs.hyprlock.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  config = lib.mkIf cfg.enable {
    programs.hyprlock = {
      enable = true;
      package = hyprlockPackages.hyprlock;

      settings = {
        # general = {
        #   disable_loading_bar = true;
        #   grace = 300;
        #   hide_cursor = true;
        #   no_fade_in = false;
        # };

        # background = [
        #   {
        #     path = "screenshot";
        #     blur_passes = 3;
        #     blur_size = 8;
        #   }
        # ];

        # input-field = [
        #   {
        #     size = "200, 50";
        #     position = "0, -80";
        #     monitor = "";
        #     dots_center = true;
        #     fade_on_empty = false;
        #     font_color = "rgb(202, 211, 245)";
        #     inner_color = "rgb(91, 96, 120)";
        #     outer_color = "rgb(24, 25, 38)";
        #     outline_thickness = 5;
        #     placeholder_text = ''
        #       <span foreground="##cad3f5">Password...</span>
        #     '';

        #     shadow_passes = 2;
        #   }
        # ];
        #
        #
        #
        #
        #

        "$font" = "JetBrainsMono Nerd Font";

        general = {
          hide_cursor = false;
        };

        # uncomment to enable fingerprint authentication
        # auth = {
        #   fingerprint = {
        #     enabled = true;
        #     ready_message = "scan fingerprint to unlock";
        #     present_message = "scanning...";

        #     # In milliseconds
        #     retry_delay = 250;
        #   };
        # };

        animations = {
          enabled = true;
          bezier = "linear, 1, 1, 0, 0";
          animation = [
            "fadeIn, 1, 5, linear"
            "fadeOut, 1, 5, linear"
            "inputFieldDots, 1, 2, linear"
          ];
        };

        background = {
          monitor = "";
          # path = "screenshot";
          blur_passes = 3;
        };

        input-field = {
          monitor = "";
          size = "20%, 5%";
          outline_thickness = 3;

          # No fill
          # inner_color = "rgba(0, 0, 0, 0.0)";

          # outer_color = "rgba(33ccffee) rgba(00ff99ee) 45deg";
          # check_color = "rgba(00ff99ee) rgba(ff6633ee) 120deg";
          # fail_color = "rgba(ff6633ee) rgba(ff0066ee) 40deg";

          # font_color = "rgb(143, 143, 143)";
          fade_on_empty = false;
          rounding = 15;

          font_family = "$font";
          placeholder_text = "Input password...";
          fail_text = "$PAMFAIL";

          # uncomment to use a letter instead of a dot to indicate the typed password
          # dots_text_format = "*";
          # dots_size = 0.4;

          dots_spacing = 0.3;

          # uncomment to use an input indicator that does not show the password length (similar to swaylock's input indicator)
          # hide_input = true;

          position = "0, -20";
          halign = "center";
          valign = "center";
        };

        label = [
          # Time
          {
            monitor = "";

            # ref. https://wiki.hyprland.org/Hypr-Ecosystem/hyprlock/#variable-substitution
            text = "$TIME";
            font_size = 90;
            font_family = "$font";

            position = "-30, 0";
            halign = "right";
            valign = "top";
          }

          # Date
          {
            monitor = "";

            # Update every 60 seconds
            text = ''
              cmd[update:60000] date +"%A, %d %B %Y"
            '';

            font_size = 25;
            font_family = "$font";

            position = "-30, -150";
            halign = "right";
            valign = "top";
          }

          {
            monitor = "";
            text = "$LAYOUT[en,ru]";
            font_size = 24;
            onclick = "hyprctl switchxkblayout all next";

            position = "250, -20";
            halign = "center";
            valign = "center";
          }
        ];
      };
    };
  };
}
