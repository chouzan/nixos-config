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

        (lib.mkIf modules.programs.nushell.enable {
          nu = true;
        })

        (lib.mkIf modules.bundles.dev.elixir.enable {
          elixir = true;
        })
      ];

      # -- Languages -----------------------------------------------------------

      # TODO: Set based on modules
      languages =
        let
          elixirSettings = {
            language_servers = [
              "expert"
              "!elixir-ls"
              "!next-ls"
              "!lexical"
            ];

            formatter = "language_server";
            format_on_save = "on";
          };

          jsonSettings = {
            formatter = "prettier";
            format_on_save = "on";

            prettier = {
              allowed = true;
              plugins = [ "prettier-plugin-multiline-arrays" ];
              multilineArraysWrapThreshold = 1;
            };
          };
        in
        {
          Nix = {
            language_servers = [ "nixd" ];
            formatter = "language_server";
            format_on_save = "on";
          };

          Nu = {
            formatter.external = {
              command = "nufmt";
              arguments = [ "--stdin" ];
            };

            format_on_save = "on";
          };

          Elixir = elixirSettings;
          EEx = elixirSettings;
          HEEx = elixirSettings;

          JSON = jsonSettings;
          JSONC = jsonSettings;
        };

      # -- LSPs ----------------------------------------------------------------

      lsp = {
        nixd.settings.nixd.formatting = [
          "nixfmt"
          "-"
        ];

        expert.binary.arguments = [ "--stdio" ];
      };
    };
  };
}
