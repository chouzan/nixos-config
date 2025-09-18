{ pkgs, inputs, ... }:

let
  hyprlandPackages = inputs.hyprland.packages.${pkgs.system};
  hyprlandPlugins = inputs.hyprland-plugins.packages.${pkgs.system};
in
{
  imports = [
    ./hyprland-config.nix
    ./hyprland-hyprlock-config.nix
    ./hyprland-hypridle-config.nix
    ./hyprland-plugin.nix
  ];

  config = {
    home.packages = with pkgs; [
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

      # Set to null because it's being installed via NixOS module
      package = null;

      # Use the one from flake
      portalPackage = hyprlandPackages.xdg-desktop-portal-hyprland;

      plugins = with hyprlandPlugins; [
        hyprbars
      ];
    };

    xdg.portal = {
      enable = true;
      xdgOpenUsePortal = true;
      extraPortals = [ pkgs.kdePackages.xdg-desktop-portal-kde ];

      config.hyprland = {
        default = [
          "hyprland"
          "kde"
        ];
      };
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
