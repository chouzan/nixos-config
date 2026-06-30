{
  osConfig,
  lib,
  pkgs,
  ...
}:

let
  inherit (osConfig) modules;
  cfg = modules.bundles;
in
{
  config = lib.mkMerge [
    (lib.mkIf cfg.dev.enable {
      home.packages = with pkgs; [
        devenv
        git-lfs
      ];

      programs.direnv = lib.mkMerge [
        {
          enable = true;
        }

        (lib.mkIf cfg.dev.nix.enable {
          nix-direnv.enable = true;
        })

        (lib.mkIf modules.programs.zsh.enable {
          enableZshIntegration = true;
        })
      ];
    })

    (lib.mkIf cfg.dev.nix.enable {
      home.packages = with pkgs; [
        nixd
        nixfmt
        nixfmt-tree
        statix
        deadnix
        nix-tree
        nix-output-monitor
      ];
    })

    (lib.mkIf cfg.dev.elixir.enable {
      home.packages = with pkgs; [
        beamPackages.elixir
        elixir-expert
      ];
    })

    (lib.mkIf cfg.dev.elixir.phoenix.enable {
      home.packages = with pkgs; [ inotify-tools ];
    })

    (lib.mkIf cfg.dev.ruby.enable {
      home.packages = with pkgs; [ ruby ];
    })

    (lib.mkIf cfg.dev.python.enable {
      home.packages = with pkgs; [ python3 ];
      programs.uv.enable = true;
    })

    (lib.mkIf cfg.dev.node.enable {
      home.packages = with pkgs; [ nodejs ];
      programs.bun.enable = true;
    })
  ];
}
