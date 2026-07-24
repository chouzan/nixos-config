{
  osConfig,
  lib,
  pkgs,
  ...
}:

let
  inherit (osConfig) modules;
  cfg = modules.programs.gnupg;
in
{
  config = lib.mkIf cfg.enable {
    programs.gpg.enable = true;

    services.gpg-agent = {
      enable = true;
      enableSshSupport = modules.programs.ssh.enable;
      enableZshIntegration = modules.programs.zsh.enable;
      pinentry.package = pkgs.pinentry-rofi;
    };
  };
}
