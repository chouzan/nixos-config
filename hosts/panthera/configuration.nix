{ ... }:

{
  imports = [
    ./hardware-configuration.nix

    ./disko.nix
    ./grub-chainload.nix

    ../shared/system/locale.nix
    ../shared/hardware/logitech/udev-rules.nix
    ../shared/hardware/x870e-tomahawk/power-management.nix

    ../../modules/nixos

    ../../profiles/base.nix
    ../../profiles/hardware/desktop.nix
    ../../profiles/hardware/amd.nix
    ../../profiles/environment/desktop.nix
    ../../profiles/environment/hyprland.nix
    ../../profiles/role/development.nix
    ../../profiles/role/media.nix
  ];

  system.stateVersion = "26.05";

  modules = {
    monitors = [
      {
        name = "DP-2";
        primary = true;
        width = 5120;
        height = 2160;
        refreshRate = 165;
        position = "0x0";
        # scale = 1;
        scale = 1.07;
        hyprland.workspace = "primary";
      }

      {
        name = "DP-3";
        width = 3440;
        height = 1440;
        refreshRate = 144;
        # position = "840x-1440";
        position = "680x-1440";
        scale = 1;
        hyprland.workspace = "auxiliary";
      }
    ];
  };
}
