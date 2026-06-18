{ config, lib, ... }:

let
  cfg = config.modules.system.dns;
in
{
  config = lib.mkIf cfg.encrypted.enable {
    services.dnscrypt-proxy = {
      enable = true;

      # Reference: https://github.com/DNSCrypt/dnscrypt-proxy/blob/master/dnscrypt-proxy/example-dnscrypt-proxy.toml
      settings = {
        # ipv6_servers = true;
        require_dnssec = true;

        listen_addresses = [
          "127.0.0.1:53"
          # "[::1]:53"
        ];
      };
    };

    systemd.services.dnscrypt-proxy.serviceConfig.StateDirectory = "dnscrypt-proxy";

    networking = {
      nameservers = [
        "127.0.0.1"
        # "::1"
      ];

      # Prevent NetworkManager from overwriting resolv.conf
      networkmanager.dns = "none";
    };
  };
}
