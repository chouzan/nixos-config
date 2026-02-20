{ osConfig, lib, ... }:

let
  inherit (osConfig) modules;
  cfg = modules.programs.zed;
in
{
  config = lib.mkIf cfg.enable {
    programs.zed-editor.userSettings = {
      # Reference: https://github.com/zed-industries/extensions/tree/main/extensions
      auto_install_extensions = lib.mkMerge [
        (lib.mkIf modules.bundles.container.enable {
          dockerfile = true;
          docker-compose = true;
        })

        (lib.mkIf modules.bundles.dev.enable {
          toml = true;
        })

        (lib.mkIf modules.bundles.dev.nix.enable {
          nix = true;
        })

        (lib.mkIf modules.bundles.dev.elixir.enable {
          elixir = true;
        })
      ];

      # TODO: Set based on modules
      languages = {
        JSON = {
          prettier = {
            plugins = [
              "prettier-plugin-mltiline-arrays"
            ];

            multilineArraysWrapThreshold = 1;
          };
        };

        Elixir = {
          language_servers = [
            "expert"
            "!elixir-ls"
            "!next-ls"
            "!lexical"
          ];
        };

        Nix = {
          language_servers = [
            "nixd"
          ];
        };
      };
    };
  };
}
