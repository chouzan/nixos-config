# TODO: Update config

{ osConfig, lib, ... }:

let
  inherit (osConfig) stylix modules;
  cfg = modules.programs.zed;
in
{
  imports = [
    ./languages.nix
    ./context-servers.nix
    ./agent-profiles.nix
  ];

  config = lib.mkIf cfg.enable {
    programs.zed-editor = {
      mutableUserSettings = true;

      userSettings = {
        # UI & Appearance
        # Set by Stylix
        #
        # theme = "Base16 ${stylix.colors.scheme-name}";
        # ui_font_family = stylix.fonts.sansSerif.name;
        # ui_font_size = stylix.fonts.sizes.applications * 4.0 / 3.0;
        # buffer_font_family = stylix.fonts.monospace.name;
        # buffer_font_size = stylix.fonts.sizes.terminal * 4.0 / 3.0;

        buffer_font_features = {
          zero = true;
          calt = true;
        };

        vim_mode = true;
        soft_wrap = "none";

        terminal = lib.mkIf modules.stylix.enable {
          font_size = stylix.fonts.sizes.terminal * 4.0 / 3.0;
        };

        features.edit_prediction_provider = "zed";

        agent = {
          default_model = {
            provider = "anthropic";
            model = "claude-sonnet-4-5-thinking-latest";
          };

          always_allow_tool_actions = true;
          play_sound_when_agent_done = true;
          use_modifier_to_send = true;
        };
      };
    };
  };
}
