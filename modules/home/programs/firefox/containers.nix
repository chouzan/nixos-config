{
  osConfig,
  lib,
  pkgs,
  ...
}:

let
  cfg = osConfig.modules.programs.firefox;
in
{
  config = lib.mkIf cfg.enable {
    programs.firefox.profiles.default = {
      extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [ multi-account-containers ];

      settings = {
        # Enable container
        "privacy.userContext.enabled" = true;
        "privacy.userContext.ui.enabled" = true;
        # Disable container sync to prevent conflicts
        "services.sync.prefs.sync.privacy.userContext.enabled" = false;
        "services.sync.prefs.sync-seen.privacy.userContext.enabled" = true;
      };

      containersForce = true;

      containers = {
        "firefox-container-1" = {
          id = 1;
          name = "Personal";
          color = "blue";
          icon = "fingerprint";
        };

        "firefox-container-2" = {
          id = 2;
          name = "Zestead";
          color = "turquoise";
          icon = "briefcase";
        };

        "firefox-container-3" = {
          id = 3;
          name = "Product Research";
          color = "purple";
          icon = "briefcase";
        };

        "firefox-container-4" = {
          id = 4;
          name = "Profession";
          color = "blue";
          icon = "briefcase";
        };

        "firefox-container-5" = {
          id = 5;
          name = "Work";
          color = "orange";
          icon = "briefcase";
        };

        "firefox-container-6" = {
          id = 6;
          name = "Finance";
          color = "green";
          icon = "dollar";
        };

        "firefox-container-7" = {
          id = 7;
          name = "Transaction";
          color = "pink";
          icon = "cart";
        };

        "firefox-container-8" = {
          id = 8;
          name = "Social";
          color = "turquoise";
          icon = "fingerprint";
        };

        "firefox-container-9" = {
          id = 9;
          name = "Anonymous";
          color = "red";
          icon = "fingerprint";
        };

        "firefox-container-10" = {
          id = 10;
          name = "Mum's";
          color = "purple";
          icon = "fingerprint";
        };
      };
    };
  };
}
