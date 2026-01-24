{
  osConfig,
  lib,
  pkgs,
  ...
}:

let
  cfg = osConfig.modules.desktop.hyprland;
in
{
  imports = [
    ./settings
    ./hyprlock.nix
    ./hypridle.nix
    ./plugins.nix
  ];

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      nordzy-cursor-theme

      kdePackages.qtwayland
      kdePackages.dolphin
      kdePackages.gwenview
      kdePackages.kwallet
      rofi

      # Clipboard manager
      wl-clipboard

      # Screenshot
      grim
      slurp
      satty

      # Screen recording
      wf-recorder
      wl-screenrec
    ];

    programs = {
      hyprpanel.enable = true;

      kitty = {
        enable = true;
        shellIntegration.enableZshIntegration = true;

        # font = {
        #   package = pkgs.nerd-fonts.jetbrains-mono;
        #   name = "JetBrainsMono Nerd Font";
        # };
      };
    };

    wayland.windowManager.hyprland = {
      enable = true;

      # Set Hyprland and XDPH packages to null to use the ones from the NixOS module
      package = null;
      portalPackage = null;

      plugins = with pkgs.hyprlandPlugins; [
        hyprbars
      ];
    };

    services = {
      hyprpolkitagent.enable = true;

      hyprpaper.enable = true;

      # Clipboard manager
      clipse.enable = true;

      # NOTE: switch to true if not using hyprpanel
      mako.enable = false;
    };
  };
}
