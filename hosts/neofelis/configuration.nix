# Storage: Managed by disko.nix
# See docs/STORAGE_DESIGN.md for details

{
  pkgs,
  inputs,
  machine,
  ...
}:

let
  inherit (machine) hostname user;
in
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix

    inputs.disko.nixosModules.disko
    ./disko.nix

    ../../modules/nixos

    ../../profiles/base.nix
    ../../profiles/hardware/desktop.nix
    ../../profiles/hardware/amd.nix
    ../../profiles/environment/desktop.nix
    ../../profiles/environment/hyprland.nix
    ../../profiles/role/development.nix
    ../../profiles/role/media.nix
  ];

  # Use latest kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = hostname;
  # networking.wireless.enable = true; # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone and use local time (Windows dual-boot compatible)
  time = {
    timeZone = "Asia/Jakarta";
    hardwareClockInLocalTime = true; # Makes Linux use local time like Windows
  };

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${user.username} = {
    isNormalUser = true;
    description = user.name;

    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "26.05"; # Did you read the comment?

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
        hyprland.workspace = "main";
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
