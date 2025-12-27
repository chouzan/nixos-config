{ lib, ... }:

{
  imports = [
    ./monitors.nix
  ];

  options.modules.desktop.hyprland.enable = lib.mkEnableOption "Hyprland Wayland compositor";
}
