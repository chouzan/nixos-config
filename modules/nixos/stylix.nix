{ pkgs, ... }:

{
  stylix = {
    enable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark.yaml";

    override = {
      # Background
      base00 = "#282828";

      # Soft background (darkest grey)
      base01 = "#3c3836";

      # Light background (dark grey)
      base02 = "#504945";

      # Dark foreground (bright background)
      base03 = "#665c54";

      # Muted foreground (light grey)
      base04 = "#d5c4a1";

      # Foreground
      base05 = "#ebdbb2";

      # Soft foreground
      base06 = "#fbf1c7";

      # Light foreground
      base07 = "#f9f5d7";

      # Red
      base08 = "#cc241d";

      # Orange
      base09 = "#d65d0e";

      # Yellow
      base0A = "#d79921";

      # Green
      base0B = "#98971a";

      # Cyan
      base0C = "#689d6a";

      # Blue
      base0D = "#458588";

      # Magenta
      base0E = "#b16286";

      # Brown (or dark red/extra/deprecated)
      base0F = "#9d0006";
    };

    fonts = {
      serif = {
        package = pkgs.merriweather;
        name = "Merriweather";
      };

      sansSerif = {
        package = pkgs.inter;
        name = "Inter";
      };

      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font Mono";
      };

      emoji = {
        package = pkgs.noto-fonts-emoji;
        name = "Noto Color Emoji";
      };

      sizes = {
        desktop = 11;
        popups = 11;
        applications = 11;
        terminal = 11;
      };
    };

    opacity = {
      desktop = 1.0;
      popups = 1.0;
      applications = 1.0;
      terminal = 0.9;
    };

    image = ../stylix/images/wallpaper.jpg;
    polarity = "dark";
  };
}
