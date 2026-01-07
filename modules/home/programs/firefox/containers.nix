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
        "01-personal" = {
          id = 1;
          name = "Personal";
          color = "blue";
          icon = "fingerprint";
        };

        "02-zestead" = {
          id = 2;
          name = "Zestead";
          color = "turquoise";
          icon = "briefcase";
        };

        "03-research" = {
          id = 3;
          name = "Product Research";
          color = "purple";
          icon = "briefcase";
        };

        "04-profession" = {
          id = 4;
          name = "Profession";
          color = "blue";
          icon = "briefcase";
        };

        "05-work" = {
          id = 5;
          name = "Work";
          color = "orange";
          icon = "briefcase";
        };

        "06-finance" = {
          id = 6;
          name = "Finance";
          color = "green";
          icon = "dollar";
        };

        "07-transaction" = {
          id = 7;
          name = "Transaction";
          color = "pink";
          icon = "cart";
        };

        "08-social" = {
          id = 8;
          name = "Social";
          color = "turquoise";
          icon = "fingerprint";
        };

        "09-anonymous" = {
          id = 9;
          name = "Anonymous";
          color = "red";
          icon = "fingerprint";
        };

        "10-mum" = {
          id = 10;
          name = "Mum's";
          color = "purple";
          icon = "fingerprint";
        };
      };
    };
  };
}
