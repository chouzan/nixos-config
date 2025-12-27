_:

{
  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
        "verified-fetches"
      ];

      # Already default to false, just want to be extra careful
      accept-flake-config = false;

      # Use all CPU cores defined by the cores setting
      max-jobs = "auto";

      # Use all available CPU cores in the system
      cores = 0;

      auto-optimise-store = true;

      # Auto-cleanup store on min-free
      min-free = 5000 * 1000000;

      # Stop auto-cleanup when max-free reached
      max-free = 15000 * 1000000;

      substituters = [
        "https://cache.nixos.org?priority=1"
        "https://nix-community.cachix.org?priority=2"
        "https://devenv.cachix.org?priority=3"
        "https://cachix.cachix.org?priority=4"
        "https://hyprland.cachix.org?priority=5"
        "https://numtide.cachix.org?priority=6"
        "https://nixpkgs-wayland.cachix.org?priority=7"
      ];

      trusted-substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
        "https://devenv.cachix.org"
        "https://cachix.cachix.org"
        "https://hyprland.cachix.org"
        "https://numtide.cachix.org"
        "https://nixpkgs-wayland.cachix.org"
      ];

      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
        "cachix.cachix.org-1:eWNHQldwUO7G2VkjpnjDbWwy4KQ/HNxht7H4SSoMckM="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
        "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
      ];
    };

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than=30d";
    };
  };
}
