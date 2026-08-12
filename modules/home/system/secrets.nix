{
  osConfig,
  config,
  lib,
  ...
}:

let
  inherit (osConfig) modules;

  secretFilePaths = {
    SOPS_ANTHROPIC_API_KEY_FILE = config.sops.secrets.anthropic_api_key.path;
    SOPS_OPENAI_API_KEY_FILE = config.sops.secrets.openai_api_key.path;
    SOPS_ONEMAP_USERNAME_FILE = config.sops.secrets.onemap_username.path;
    SOPS_ONEMAP_PASSWORD_FILE = config.sops.secrets.onemap_password.path;
  };
in
{
  sops = {
    defaultSopsFile = ../../../.secrets/secrets.home.yaml;
    age.keyFile = "${modules.my.keyHome}/age/home.key";

    secrets = {
      anthropic_api_key = { };
      openai_api_key = { };
      onemap_username = { };
      onemap_password = { };
    };
  };

  home.file."${modules.my.scriptHome}/sops_nix/load_secrets.sh" = {
    text = ''
      #!/usr/bin/env bash
      ${lib.hm.shell.exportAll secretFilePaths}
    '';

    executable = true;
  };

  programs.zsh.initContent = lib.mkIf modules.programs.zsh.enable (
    lib.mkOrder 1500 ''
      source ${modules.my.scriptHome}/sops_nix/load_secrets.sh
      # export <SOME_ENV>=$(cat "$SOPS_<SOME_ENV>_FILE" 2>/dev/null || echo "")
    ''
  );

  programs.nushell.environmentVariables = lib.mkIf modules.programs.nushell.enable secretFilePaths;
}
