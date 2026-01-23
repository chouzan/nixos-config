{
  osConfig,
  config,
  lib,
  pkgs,
  machine,
  ...
}:

let
  inherit (osConfig) modules;
  inherit (machine) hostname;

  cfg = modules.programs.zsh;
in
{
  config = lib.mkIf cfg.enable {
    programs = {
      zsh = {
        enable = true;

        # TODO: remove when upgrading home-manager
        # to version = > 26.05 (default behaviour)
        dotDir = "${config.xdg.configHome}/zsh";

        plugins = with pkgs; [
          {
            inherit (zsh-vi-mode) src;
            name = zsh-vi-mode.pname;
          }

          {
            inherit (zsh-fast-syntax-highlighting) src;

            name = zsh-fast-syntax-highlighting.pname;
            file = "fast-syntax-highlighting.plugin.zsh";
          }

          {
            inherit (zsh-autosuggestions) src;
            name = zsh-autosuggestions.pname;
          }

          {
            inherit (zsh-completions) src;
            name = zsh-completions.pname;
          }

          {
            inherit (zsh-you-should-use) src;
            name = zsh-you-should-use.pname;
          }

          {
            inherit (zsh-z) src;
            name = zsh-z.pname;
          }
        ];

        completionInit = "autoload -U compinit && compinit -u";

        initContent =
          let
            init = lib.mkOrder 500 ''
              export HOSTNAME=${hostname}
            '';

            zshZSettings = lib.mkOrder 1000 ''
              zstyle ':completion:*' menu select
            '';

            zshZvmEnv = lib.mkIf modules.stylix.enable (
              let
                colours = config.lib.stylix.colors.withHashtag;
              in
              lib.mkOrder 1000 ''
                ZVM_VI_HIGHLIGHT_BACKGROUND=${colours.base03}
                ZVM_VI_HIGHLIGHT_FOREGROUND=${colours.base05}
              ''
            );
          in
          lib.mkMerge [
            init
            zshZSettings
            zshZvmEnv
          ];
      };

      starship = {
        enable = true;
        enableZshIntegration = true;
        settings = fromTOML (builtins.readFile ./starship-settings.toml);
      };
    };
  };
}
