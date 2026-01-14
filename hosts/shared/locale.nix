{ lib, ... }:

{
  time = {
    timeZone = lib.mkDefault "Asia/Jakarta";

    # Make Linux use local time like Windows (dual-boot compatible)
    hardwareClockInLocalTime = lib.mkDefault true;
  };

  # Set localisation
  i18n.defaultLocale = lib.mkDefault "en_GB.UTF-8";

  # Set keyboard layout
  services.xserver.xkb = {
    layout = lib.mkDefault "us";
    variant = lib.mkDefault "";
  };
}
