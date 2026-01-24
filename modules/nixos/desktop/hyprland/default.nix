{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.modules.desktop.hyprland;
in
{
  config = lib.mkIf cfg.enable {
    programs = {
      hyprland = {
        enable = true;

        # Include the system's bin path to systemd
        # Already set to true by default for version >= 0.41.2
        # Just want to make sure
        systemd.setPath.enable = true;

        # Let Hyprland launch via the Unified Wayland Session Manager (UWSM)
        withUWSM = true;
      };
    };

    xdg.portal = {
      enable = true;

      extraPortals = with pkgs; [
        kdePackages.xdg-desktop-portal-kde
      ];

      config.hyprland = {
        default = [
          "hyprland"
          "kde"
        ];
      };
    };

    services = {
      displayManager = {
        enable = true;
        defaultSession = "hyprland";

        sddm = {
          # Enable SDDM as the graphical login manager
          enable = true;

          # Enable experimental Wayland support
          wayland.enable = true;
        };
      };
    };

    # Essential system packages for Hyprland
    environment.systemPackages = with pkgs; [
      brightnessctl
      playerctl
      wireplumber
    ];

    # Needed for some Wayland apps to behave properly with multi-monitor setups
    environment.sessionVariables.NIXOS_OZONE_WL = "1";
  };
}
