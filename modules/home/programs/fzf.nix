{
  osConfig,
  lib,
  pkgs,
  ...
}:

let
  inherit (osConfig) modules;
  cfg = modules.programs.fzf;
in
{
  config = lib.mkIf cfg.enable {
    programs.fzf.enable = true;

    programs.zsh.initContent = lib.mkIf modules.programs.zsh.enable (
      lib.mkOrder 1000 ''
        zvm_after_init_commands+=('source <(${pkgs.fzf}/bin/fzf --zsh)')
      ''
    );
  };
}
