{ ... }:

{
  imports = [
    ./hardware-configuration.nix

    # TODO: Check if it actually needed
    ./hardware-patch.nix

    ./storage.nix

    ../shared/system/locale.nix
    ../shared/hardware/logitech/udev-rules.nix

    ../../modules/nixos

    ../../profiles/base.nix
    ../../profiles/hardware/laptop.nix
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
        name = "eDP-1";
        primary = true;
        width = 2880;
        height = 1800;
        refreshRate = 90;
        position = "0x0";
        scale = 1.5;
        hyprland.workspace = "other";
      }

      {
        name = "DP-4";
        width = 3440;
        height = 1440;
        refreshRate = 144;
        position = "auto";
        scale = 1;
        hyprland.workspace = "primary";
      }
    ];

    programs.bitwarden.enable = true;
  };
}
