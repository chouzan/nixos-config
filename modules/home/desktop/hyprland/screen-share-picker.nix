{
  osConfig,
  inputs,
  lib,
  pkgs,
  ...
}:

let
  cfg = osConfig.modules.desktop.hyprland;
  system = pkgs.stdenv.hostPlatform.system;
  picker = inputs.hyprland-preview-share-picker.packages.${system}.default;
  colours = osConfig.lib.stylix.colors.withHashtag;
  font = osConfig.stylix.fonts.sansSerif.name;

  pickerStyle = pkgs.writeText "hyprland-preview-share-picker.css" ''
    * {
      color: ${colours.base05};
      font-family: "${font}";
    }

    .window {
      background: ${colours.base00};
      border: 2px solid ${colours.base02};
      border-radius: 8px;
    }

    tabs {
      padding: 8px 16px;
    }

    tabs > tab {
      margin-right: 16px;
    }

    .tab-label {
      color: ${colours.base04};
    }

    tabs > tab:checked > .tab-label,
    tabs > tab:focus > .tab-label {
      color: ${colours.base0D};
    }

    .page {
      padding: 16px;
    }

    flowboxchild > .card,
    button > .card {
      background: ${colours.base01};
      border: 2px solid transparent;
      border-radius: 8px;
      padding: 5px;
    }

    flowboxchild:active > .card,
    flowboxchild:selected > .card,
    button:active > .card,
    button:selected > .card,
    button:focus > .card {
      border-color: ${colours.base0D};
    }

    .image {
      border-radius: 6px;
    }

    .image-label {
      padding: 4px;
    }

    .region-button {
      background: ${colours.base0D};
      border-radius: 6px;
      color: ${colours.base00};
      padding: 8px 16px;
    }
  '';

  yamlFormat = pkgs.formats.yaml { };
in
{
  config = lib.mkIf cfg.enable {
    home.packages = [ picker ];

    xdg.configFile = {
      "hypr/xdph.conf".text = ''
        screencopy {
          custom_picker_binary = ${lib.getExe' picker "hyprland-preview-share-picker"}
        }
      '';

      "hyprland-preview-share-picker/config.yaml".source =
        yamlFormat.generate "hyprland-preview-share-picker.yaml"
          {
            stylesheets = [ pickerStyle ];
          };
    };
  };
}
