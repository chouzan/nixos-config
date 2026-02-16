{ lib, ... }:

{
  imports = [
    ./monitors.nix
    ./window-rules.nix
  ];

  options.modules.desktop.hyprland.enable = lib.mkEnableOption "Hyprland Wayland compositor";
}
