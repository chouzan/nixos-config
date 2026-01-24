{
  description = "NixOS configuration flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/x86_64-linux";

    nur = {
      url = "github:nix-community/NUR";

      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
      };
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    quadlet-nix.url = "github:SEIAROTg/quadlet-nix";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
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
        pre-commit-hooks.follows = "git-hooks";
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

    # NOTE: Building Zed may cause LimitNOFILE error.
    # Build it with:
    # sudo bash -lc 'ulimit -n 1048576; nixos-rebuild switch --option cores 4 --option max-jobs 4'
    zed-editor = {
      url = "github:zed-industries/zed";

      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-compat.follows = "flake-compat";
        rust-overlay.follows = "rust-overlay";
      };
    };

    claude-desktop = {
      url = "github:k3d3/claude-desktop-linux-flake";

      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };

    mcp-proxy = {
      url = "github:tidewave-ai/mcp_proxy_rust";
      flake = false;
    };

    stylix = {
      url = "github:nix-community/stylix";

      inputs = {
        nixpkgs.follows = "nixpkgs";
        systems.follows = "systems";
        flake-parts.follows = "flake-parts";
        nur.follows = "nur";
      };
    };

    # Transitive dependencies

    nixpkgs-lib.url = "github:nix-community/nixpkgs.lib";

    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs-lib";
    };

    flake-compat.url = "github:NixOS/flake-compat";

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

      inputs = {
        nixpkgs.follows = "nixpkgs";
        systems.follows = "systems";
        hyprutils.follows = "hyprutils";
      };
    };

    git-hooks = {
      url = "github:cachix/git-hooks.nix";

      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-compat.follows = "flake-compat";
      };
    };

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self, nixpkgs, ... }@inputs:
    let
      utils = import ./lib/utils.nix { inherit (nixpkgs) lib; };
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      overlays = import ./overlays { inherit inputs system; };

      # TODO: Consider moving user/XDG configuration to proper options system
      # Options:
      # 1. Create modules/options/user.nix with config.modules.user.*
      # 2. Profiles/hosts set these options, modules read them
      # 3. Keep mkUser here for "obvious" entry point, but derive XDG in modules
      # Current approach is fine for personal config, but adds coupling to flake.nix
      mkUser = username: rec {
        inherit username;
        homeDir = "/home/${username}";
        dataHome = "${homeDir}/.local/share";
        stateHome = "${homeDir}/.local/state";
        configHome = "${homeDir}/.config";
        cacheHome = "${homeDir}/.cache";
        runtimeDir = "/run/user/1000";
        name = "Muhammad H. Fauzan";
        gitEmail = "14904191+chouzan@users.noreply.github.com";
      };

      # Default user for most hosts
      user = mkUser "chouzan";

      mkMachine = utils.mkMachineDefaults { inherit inputs system user; };

      # TODO: Consider hosts/shared/ for common configs (e.g., home.nix)
      # Currently home.nix files are duplicated across hosts with little difference
      # Options:
      # - hosts/shared/home.nix imported by hosts
      # - profiles/home/base.nix following profile pattern
      # - Explicit homeManagerConfig paths instead of utils.nix magic
      # See also: lib/utils.nix autoResolveHomeManagerConfig magic
      #
      # TODO: Add per-host extraModules support to machine definitions
      # e.g., extraModules = [ inputs.disko.nixosModules.disko ];
      # This would allow hosts like panthera to declare disko without affecting acinonyx
      #
      # TODO: Consider integrating leopardus (installer) into machines with aliases
      # Currently separate due to extraModules (sops, quadlet, stylix) not being needed for live ISO
      #
      # TODO: Evaluate folder structure as project grows
      # Current: hosts/, profiles/, modules/, lib/, scripts/, docs/, overlays/
      #
      # TODO: Introduce `nixosadm` command for unified admin tasks
      # - Similar to `eos` from EndeavourOS
      # - Commit hardware-configuration.nix and stateVersion changes after install
      # - System maintenance, updates, garbage collection
      # - Explore integration with nh (github:nix-community/nh) for better UX
      machines = {
        workstation = mkMachine {
          hostname = "panthera";
          aliases = [ "desktop" ];
        };

        lab = mkMachine {
          hostname = "neofelis";
        };

        laptop = mkMachine {
          hostname = "acinonyx";
          user = mkUser "muhifauzan";
        };

        server = mkMachine {
          homeManager = false;
        };
      };

      # TODO: Make extraModules more flexible to support per-host modules
      # Currently these are applied to ALL hosts. Consider adding a mechanism
      # for hosts to declare additional modules (e.g., disko for panthera only)
      # without polluting other host configurations.
      extraModules = with inputs; [
        sops-nix.nixosModules.sops
        quadlet-nix.nixosModules.quadlet
        stylix.nixosModules.stylix
      ];

      extraHomeManagerModules = with inputs; [
        sops-nix.homeManagerModules.sops
        quadlet-nix.homeManagerModules.quadlet
      ];
    in
    {
      nixosConfigurations =
        utils.buildConfigurations machines extraModules extraHomeManagerModules overlays
        // {
          leopardus = nixpkgs.lib.nixosSystem {
            inherit system;
            modules = [ ./hosts/leopardus/configuration.nix ];
          };
        };

      # Convenience package outputs
      packages.${system} = {
        leopardus = self.nixosConfigurations.leopardus.config.system.build.isoImage;
        installer = self.nixosConfigurations.leopardus.config.system.build.isoImage; # Alias
      };

      formatter.${system} = inputs.treefmt-nix.lib.mkWrapper pkgs {
        projectRootFile = "flake.nix";
        programs.nixfmt.enable = true;
        settings.global.includes = [ "*.nix" ];
        settings.global.excludes = [ ".knowledge/*" ];
      };

      debug = { inherit machines utils; };
    };
}
