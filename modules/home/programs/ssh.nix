{ osConfig, lib, ... }:

let
  cfg = osConfig.modules.programs.ssh;
in
{
  config = lib.mkIf cfg.enable {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;

      settings = {
        "github.com" = {
          HostName = "github.com";
          User = "git";
          IdentityFile = "~/.ssh/id_ed25519";
          AddKeysToAgent = "confirm";
        };

        "gitlab.com" = {
          HostName = "gitlab.com";
          User = "git";
          IdentityFile = "~/.ssh/id_ed25519";
          AddKeysToAgent = "confirm";
        };
      };
    };
  };
}
