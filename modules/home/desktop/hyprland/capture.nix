{
  osConfig,
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = osConfig.modules.desktop.hyprland;
  inherit (config.xdg) userDirs;

  runtimeInputs = with pkgs; [
    grim
    hyprland
    libnotify
    satty
    slurp
    systemd
    wl-screenrec
    xdg-utils
  ];

  hypr-capture = pkgs.writeNuBinChecked "hypr-capture" {
    makeWrapperArgs = [
      "--prefix"
      "PATH"
      ":"
      "${lib.makeBinPath runtimeInputs}"
      "--set"
      "HYPR_CAPTURE_SCREENSHOT_DIR"
      "${userDirs.pictures}/Screenshot"
      "--set"
      "HYPR_CAPTURE_RECORDING_DIR"
      "${userDirs.videos}/Recording"
    ];
  } ./capture.nu;
in
{
  config = lib.mkIf cfg.enable {
    home.packages = [ hypr-capture ];
  };
}
