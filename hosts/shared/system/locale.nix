{ libs, ... }:

let
  inherit (libs) utils;
in
{
  # Make Linux use local time like Windows (dual-boot compatible)
  time.hardwareClockInLocalTime = utils.mkHostDefault true;

  # Set localisation
  i18n.defaultLocale = utils.mkHostDefault "en_GB.UTF-8";

  services = {
    automatic-timezoned.enable = utils.mkHostDefault true;

    # Set keyboard layout
    xserver.xkb = {
      layout = utils.mkHostDefault "us";
      variant = utils.mkHostDefault "";
    };
  };
}
