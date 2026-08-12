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

      # Screenshot
      grim
      slurp
      satty

      # Screen recording
      wf-recorder
      wl-screenrec
    ];

    programs = {
      kitty = {
        enable = true;

        # Kitty derives this from shellIntegration.mode, not from home.shell.
        shellIntegration.enableZshIntegration = modules.programs.zsh.enable;

        keybindings = {
          # \x17 = Ctrl+W (backward-kill-word)
          "ctrl+backspace" = "send_text all \\x17";
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

      plugins = with pkgs.hyprlandPlugins; [
        hyprbars
      ];
    };

    services = {
      hyprpolkitagent.enable = true;
      hyprpaper.enable = true;

      # Clipboard manager
      clipse.enable = true;

      mako.enable = true;
    };
  };
}
