{
  flake.modules.nixos.system-dns = { lib, ... }: {
    options.modules.system.dns.encrypted.enable = lib.mkEnableOption "encrypted DNS via dnscrypt-proxy";
  };
}
