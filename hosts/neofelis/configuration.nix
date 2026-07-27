{ ... }:

{
  imports = [
    ./hardware-configuration.nix

    ./disko.nix

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

    ../shared/settings/desktop/monitors.nix
  ];

  system.stateVersion = "26.05";

  modules = {
    desktop.hyprland.extraWindowRules = [
      {
        name = "zed-nixos";

        match = {
          class = "dev.zed.Zed";
          title = "nixos";
        };

        workspace = "special:system silent";
      }

      {
        name = "kitty-btop";

        match = {
          class = "kitty";
          title = "btop";
        };

        workspace = "special:system silent";
      }

      {
        name = "claude-desktop";
        match.class = "Claude";
        workspace = "auxiliary silent";
      }

      {
        name = "spotify";
        match.class = "spotify";
        workspace = "auxiliary silent";
      }
    ];
  };
}
