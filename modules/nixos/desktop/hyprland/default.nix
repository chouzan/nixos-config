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
      # Enable X server for SDDM greeter
      # Weston (used by SDDM's Wayland greeter) crashes on RDNA 4 GPUs
      # TODO: Re-enable wayland.enable once Weston supports RDNA 4
      xserver.enable = true;

      displayManager = {
        enable = true;
        defaultSession = "hyprland";

        sddm = {
          # Enable SDDM as the graphical login manager
          enable = true;

          # Disable experimental Wayland support
          # Weston crashes on RDNA 4 GPUs
          wayland.enable = false;
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
