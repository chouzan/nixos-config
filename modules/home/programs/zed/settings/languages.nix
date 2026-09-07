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

          # Formatting stays off until nufmt handles records reliably. See the
          # note in treefmt.nix.
          #
          # Both keys are set rather than dropped, because home-manager merges
          # this file into the one Zed already has. A key left out here keeps
          # whatever value that file holds.
          #
          # The form below is kept because it differs from the treefmt one. It
          # needs no --config, since nufmt finds nufmt.nuon by walking up from
          # the working directory.
          Nu = {
            formatter = "auto";
            format_on_save = "off";

            # formatter.external = {
            #   command = "nufmt";
            #   arguments = [ "--stdin" ];
            # };

            # format_on_save = "on";
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
