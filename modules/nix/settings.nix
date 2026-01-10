{ lib, ... }:

let
  caches = [
    {
      name = "cache.nixos.org";
      hash = "6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=";
    }

    {
      name = "nix-community.cachix.org";
      hash = "mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=";
    }

    {
      name = "cachix.cachix.org";
      hash = "eWNHQldwUO7G2VkjpnjDbWwy4KQ/HNxht7H4SSoMckM=";
    }

    {
      name = "hyprland.cachix.org";
      hash = "a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=";
    }

    {
      name = "zed-industries.cachix.org";
      hash = "fgVpvtdF+ssrgP1lB6EusuR3uM6bNcncWduKxri3u6Y=";
    }

    {
      name = "zed.cachix.org";
      hash = "/pHQ6dpMsAZk2DiP4WCL0p9YDNKWj2Q5FL20bNmw1cU=";
    }

    {
      name = "devenv.cachix.org";
      hash = "w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
    }

    {
      name = "numtide.cachix.org";
      hash = "2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE=";
    }

    {
      name = "nixpkgs-wayland.cachix.org";
      hash = "3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA=";
    }
  ];

  mkUrl = c: "https://${c.name}";
  mkKey = c: "${c.name}-1:${c.hash}";
  mkSubstituter = i: c: "${mkUrl c}?priority=${toString i}";
in
{
  nix = {
    # Disable channels since we use flakes
    # nixos-rebuild will auto-detect flake at /etc/nixos/flake.nix
    # and use networking.hostName to find the configuration
    channel.enable = false;

    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
        "verified-fetches"
      ];

      # Already default to false, just want to be extra careful
      accept-flake-config = false;

      # Use all available CPU cores for each build
      cores = 0;

      # Maximum number of local build(s) to run in parallel
      max-jobs = "auto";

      build-dir = "/nix/var/nix/builds";

      auto-optimise-store = true;

      # Auto-cleanup store when free space falls below 10 GiB
      min-free = 10 * 1024 * 1024 * 1024;

      # Stop auto-cleanup when free space reaches 25 GiB
      max-free = 25 * 1024 * 1024 * 1024;

      substituters = lib.imap1 mkSubstituter caches;
      trusted-substituters = map mkUrl caches;
      trusted-public-keys = map mkKey caches;
    };

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than=30d";
    };
  };

  systemd.tmpfiles.rules = [ "D /nix/var/nix/builds 0755 root root 0 -" ];
}
