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

    # Secret Service for the session. Apps that store credentials (Spotify,
    # browsers, etc.) talk to org.freedesktop.secrets; without a working
    # provider they prompt to create a keyring on every boot.
    #
    # Use gnome-keyring, not KWallet. On a non-KDE session KWallet's ksecretd
    # repeatedly prompts to create a "Default Keyring" and its secret-service
    # daemon hangs/errors on wallet-name edge cases (KDE bug 504656). KDE's own
    # KWallet-to-SecretService transition explicitly supports backing the
    # secret service with gnome-keyring or KeePassXC instead; gnome-keyring is
    # the standard provider for non-KDE Wayland. Its "login" keyring is
    # unlocked at login by pam_gnome_keyring with the login password, so it
    # stays silent (no dialog, no wizard), and KDE apps still reach it through
    # the standard freedesktop interface.
    #
    # Enable pam on the "login" service, NOT "sddm": SDDM sets
    # useDefaultRules = false and only substacks "login", so a rule placed on
    # "sddm" is silently dropped; the stack that runs at graphical login is
    # "login".
    services.gnome.gnome-keyring.enable = true;
    security.pam.services.login.enableGnomeKeyring = true;

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
