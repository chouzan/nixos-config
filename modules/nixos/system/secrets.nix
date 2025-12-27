{ config, ... }:

let
  inherit (config) modules;
in
{
  sops = {
    defaultSopsFile = ../../../.secrets/secrets.nixos.yaml;
    age.keyFile = "${modules.my.keyHome}/age/nixos.key";
  };
}
