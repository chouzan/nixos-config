{ libs, ... }:

let
  inherit (libs) utils;
in
{
  time = {
    timeZone = utils.mkHostDefault "Asia/Jakarta";

    # Make Linux use local time like Windows (dual-boot compatible)
    hardwareClockInLocalTime = utils.mkHostDefault true;
  };

  # Set localisation
  i18n.defaultLocale = utils.mkHostDefault "en_GB.UTF-8";

  # Set keyboard layout
  services.xserver.xkb = {
    layout = utils.mkHostDefault "us";
    variant = utils.mkHostDefault "";
  };
}
