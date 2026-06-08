{ ... }:

{
  modules = {
    monitors = [
      {
        name = "DP-1";
        primary = true;
        width = 5120;
        height = 2160;
        refreshRate = 165;
        position = "0x0";
        # scale = 1;
        scale = 1.07;

        hyprland = {
          workspace = "primary";
          bitdepth = 10;
          cm = "srgb";
        };
      }

      {
        name = "DP-2";
        width = 3440;
        height = 1440;
        refreshRate = 144;
        # position = "840x-1440";
        position = "680x-1440";
        scale = 1;
        hyprland.workspace = "auxiliary";
      }
    ];
  };
}
