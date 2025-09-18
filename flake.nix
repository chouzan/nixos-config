{
  description = "NixOS configuration flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-lib.url = "github:nix-community/nixpkgs.lib";
    systems.url = "github:nix-systems/x86_64-linux";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs-lib";
    };

    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };

    nur = {
      url = "github:nix-community/NUR";

      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
      };
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    quadlet-nix.url = "github:SEIAROTg/quadlet-nix";

    hyprutils = {
      url = "github:hyprwm/hyprutils";

      inputs = {
        nixpkgs.follows = "nixpkgs";
        systems.follows = "systems";
      };
    };

    hyprlang = {
      url = "github:hyprwm/hyprlang";

      inputs = {
        nixpkgs.follows = "nixpkgs";
        systems.follows = "systems";
        hyprutils.follows = "hyprutils";
      };
    };

    hyprland-protocols = {
      url = "github:hyprwm/hyprland-protocols";

      inputs = {
        nixpkgs.follows = "nixpkgs";
        systems.follows = "systems";
      };
    };

    hyprwayland-scanner = {
      url = "github:hyprwm/hyprwayland-scanner";

      inputs = {
        nixpkgs.follows = "nixpkgs";
        systems.follows = "systems";
      };
    };

    hyprgraphics = {
      url = "github:hyprwm/hyprgraphics";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "systems";
      inputs.hyprutils.follows = "hyprutils";
    };

    hyprland = {
      url = "github:hyprwm/Hyprland";

      inputs = {
        nixpkgs.follows = "nixpkgs";
        systems.follows = "systems";
        hyprutils.follows = "hyprutils";
        hyprlang.follows = "hyprlang";
        hyprland-protocols.follows = "hyprland-protocols";
        hyprwayland-scanner.follows = "hyprwayland-scanner";
        hyprgraphics.follows = "hyprgraphics";
      };
    };

    hypridle = {
      url = "github:hyprwm/hypridle";

      inputs = {
        nixpkgs.follows = "nixpkgs";
        systems.follows = "systems";
        hyprutils.follows = "hyprutils";
        hyprlang.follows = "hyprlang";
        hyprland-protocols.follows = "hyprland-protocols";
        hyprwayland-scanner.follows = "hyprwayland-scanner";
      };
    };

    hyprlock = {
      url = "github:hyprwm/hyprlock";

      inputs = {
        nixpkgs.follows = "nixpkgs";
        systems.follows = "systems";
        hyprutils.follows = "hyprutils";
        hyprlang.follows = "hyprlang";
        hyprwayland-scanner.follows = "hyprwayland-scanner";
        hyprgraphics.follows = "hyprgraphics";
      };
    };

    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";

      inputs = {
        nixpkgs.follows = "nixpkgs";
        systems.follows = "systems";
        hyprland.follows = "hyprland";
      };
    };

    claude-desktop = {
      url = "github:k3d3/claude-desktop-linux-flake";

      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };

    stylix = {
      url = "github:nix-community/stylix";

      inputs = {
        nixpkgs.follows = "nixpkgs";
        systems.follows = "systems";
        flake-parts.follows = "flake-parts";
      };
    };
  };

  outputs =
    { nixpkgs, ... }@inputs:
    let
      utils = import ./lib/utils.nix { lib = nixpkgs.lib; };
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      user = rec {
        username = "muhifauzan";
        homedir = "/home/${username}";
        dataHome = "${homedir}/.local/share";
        stateHome = "${homedir}/.local/state";
        configHome = "${homedir}/.config";
        cacheHome = "${homedir}/.cache";
        runtimeDir = "/run/user/1000";
        name = "Muhammad Hilmy Fauzan";
      };

      mkMachine = utils.mkMachineDefaults { inherit inputs system user; };

      machines = {
        workstation = mkMachine {
          hostname = "panthera";
          aliases = [ "pc" ];
        };

        laptop = mkMachine {
          hostname = "acinonyx";
        };

        server = mkMachine {
          homeManager = false;
        };
      };

      extraModules = [
        inputs.sops-nix.nixosModules.sops
        inputs.quadlet-nix.nixosModules.quadlet
        inputs.stylix.nixosModules.stylix
      ];

      extraHomeManagerModules = [
        inputs.sops-nix.homeManagerModules.sops
        inputs.quadlet-nix.homeManagerModules.quadlet
      ];
    in
    {
      nixosConfigurations = utils.buildConfigurations machines extraModules extraHomeManagerModules;

      formatter.${system} = inputs.treefmt-nix.lib.mkWrapper pkgs {
        projectRootFile = "flake.nix";
        programs.nixfmt.enable = true;
        settings.global.includes = [ "*.nix" ];
        settings.global.excludes = [ ".knowledge/*" ];
      };

      debug = { inherit machines utils; };
    };
}
