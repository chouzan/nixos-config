{ lib, ... }:

{
  options.modules.system = {
    dns.encrypted.enable = lib.mkEnableOption "encrypted DNS via dnscrypt-proxy";
    xdg.enable = lib.mkEnableOption "XDG directory structure management";
  };
}
