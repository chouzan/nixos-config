{
  config,
  lib,
  pkgs,
  libs,
  ...
}:

let
  inherit (config) modules;
  inherit (libs) sensitivePaths;

  cfg = modules.programs.claude-code;

  jsonFormat = pkgs.formats.json { };

  managedSettings = lib.recursiveUpdate {
    permissions.deny = sensitivePaths.claudeDenyRules {
      inherit (modules.my) keyHome;
      inherit (modules.user) homeDirectory;
    };
  } cfg.systemSettings;
in
{
  # Policy only. Managed settings outrank every other layer and cannot be
  # overridden, which is what a deny list needs: nothing running as the user,
  # including the agent itself, can weaken it. Preferences do not belong here —
  # they are merged into the writable user settings by the home module.
  config = lib.mkIf cfg.enable {
    environment.etc."claude-code/managed-settings.json".source =
      jsonFormat.generate "claude-code-managed-settings.json" managedSettings;
  };
}
