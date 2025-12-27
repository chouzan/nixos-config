{
  config,
  lib,
  pkgs,
  machine,
  ...
}:

let
  inherit (machine) user;
  cfg = config.modules.packages;
in
{
  config = lib.mkMerge [
    (lib.mkIf cfg.admin.enable {
      environment = {
        systemPackages = with pkgs; [
          dmidecode
          file
          htop
          less
          lshw
          pciutils
          usbutils
        ];

        sessionVariables = {
          LESS = "-iMRSW";
          PAGER = "less";
        };
      };
    })

    (lib.mkIf cfg.network.enable {
      users.users.${user.username}.packages = with pkgs; [
        curl
        dig
        netcat
        nmap
        wget
      ];
    })

    (lib.mkIf cfg.archive.enable {
      users.users.${user.username}.packages = with pkgs; [
        p7zip
        unzip
        zip
      ];
    })

    (lib.mkIf cfg.cli.enable {
      users.users.${user.username}.packages = with pkgs; [
        jq
        tree
        yq-go
      ];
    })
  ];
}
