# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{ pkgs, machine, ... }:

let
  inherit (machine) hostname user;
in
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix

    # Might not be needed
    ./nixos-hardware-patch.nix

    ./storage.nix
    ./udev.nix
    ../../modules/nixos
  ];

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = hostname; # Define your hostname.
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
    packages = [ ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = [
    # vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    # wget
  ];

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
  system.stateVersion = "25.05"; # Did you read the comment?

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

        hyprland = {
          workspace = "main";
        };
      }

      {
        name = "DP-4";
        width = 3440;
        height = 1440;
        refreshRate = 144;
        position = "auto";
        scale = 1;

        hyprland = {
          workspace = "workspace";
          vrr = 1;
        };
      }
    ];

    amd.enable = true;
    battery.enable = true;

    packages = {
      admin.enable = true;
      extras.enable = true;
    };

    hyprland.enable = true;

    dev = {
      nix.enable = true;

      elixir = {
        enable = true;
        phoenix.enable = true;
      };

      node.enable = true;
      python.enable = true;
    };

    ai.enable = true;

    spotify.enable = true;
  };
}
