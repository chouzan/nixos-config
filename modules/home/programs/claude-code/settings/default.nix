{ osConfig, lib, ... }:

let
  cfg = osConfig.modules.programs.claude-code;
in
{
  imports = [
    ./mcp-servers.nix
  ];

  config = lib.mkIf cfg.enable {
    programs.claude-code.settings = {
      attribution = {
        commit = "";
        pr = "";
      };

      permissions = {
        deny = [
          "Read(.secrets/**)"
          "Read(.env)"
          "Read(.env.*)"
          "Read(**/*.key)"
        ];
      };
    };
  };
}
