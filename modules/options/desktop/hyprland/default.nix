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
          Whether to load optional local Hyprland Lua configuration files.
          Local files are loaded after the generated configuration, so they
          can override module defaults without modifying the flake.
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
          Local Hyprland configuration directories relative to the home
          directory. Each directory's optional init.lua is loaded.
        '';
      };
    };
  };
}
