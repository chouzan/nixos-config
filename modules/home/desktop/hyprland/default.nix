{
  osConfig,
  lib,
  pkgs,
  ...
}:

let
  inherit (osConfig) modules;
  cfg = modules.desktop.hyprland;
in
{
  imports = [
    ./settings
    ./hyprlock.nix
    ./hypridle.nix
    ./plugins.nix
    ./capture.nix
    ./screen-share-picker.nix
    ./quickshell
    ./hypr-auto-mfact.nix
  ];

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      nordzy-cursor-theme

      kdePackages.qtwayland
      kdePackages.dolphin
      kdePackages.gwenview
      rofi

      # Clipboard manager
      wl-clipboard
    ];

    programs = {
      kitty = {
        enable = true;

        # Kitty derives this from shellIntegration.mode, not from home.shell.
        shellIntegration.enableZshIntegration = modules.programs.zsh.enable;

        keybindings = {
          # \x17 = Ctrl+W (backward-kill-word)
          "ctrl+backspace" = "send_text all \\x17";

          # NOTE: Opens a window in the working directory of the focused
          # window. The Hyprland terminal bind sends this shortcut, so
          # changing the shortcut needs the matching change in
          # settings/lua/binds.lua.
          "ctrl+shift+f12" = "new_os_window_with_cwd";
        };

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

      # uwsm binds the compositor into graphical-session.target. Home Manager
      # links hyprland-session.target to that same target and stops it while
      # the compositor starts, which tears the session down.
      #
      # Reference: https://wiki.nixos.org/wiki/Hyprland
      systemd.enable = false;

      plugins = with pkgs.hyprlandPlugins; [
        hyprbars
      ];
    };

    services = {
      hyprpolkitagent.enable = true;
      hyprpaper.enable = true;

      # Clipboard manager
      clipse.enable = true;
    };
  };
}
