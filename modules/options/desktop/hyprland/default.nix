{ lib, ... }:

let
  inherit (lib) types;
in
{
  imports = [
    ./monitors.nix
    ./window-rules.nix
  ];

  options.modules.desktop.hyprland = {
    enable = lib.mkEnableOption "Hyprland Wayland compositor";

    localSettings = {
      enable = lib.mkOption {
        type = types.bool;
        default = true;

        description = ''
          Enable local drop-in Hyprland config directories.
          Each directory gets a keep.conf placeholder (so the glob
          always matches) and a source directive appended to the
          hyprland.conf.
        '';
      };

      dirs = lib.mkOption {
        type = types.listOf types.str;
        default = [ ".config/hypr/local.d" ];

        example = [
          ".config/hypr/local.d"
          ".config/hypr/work.d"
        ];

        description = ''
          Drop-in directories for local Hyprland .conf files.
          Paths relative to home directory. Sourced at the end
          of the hyprland.conf, so local files can override
          module defaults.
        '';
      };
    };
  };
}
