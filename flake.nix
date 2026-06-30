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

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Following main — v0.55.4 and earlier don't build with GCC 16.
    # Switch back to tag pin once v0.56 is released.
    hyprland = {
      url = "github:hyprwm/Hyprland";

      inputs = {
        nixpkgs.follows = "nixpkgs";
        systems.follows = "systems";
        hyprutils.follows = "hyprutils";
        hyprlang.follows = "hyprlang";
        hyprland-protocols.follows = "hyprland-protocols";
        hyprwayland-scanner.follows = "hyprwayland-scanner";
        hyprwire.follows = "hyprwire";
        hyprgraphics.follows = "hyprgraphics";
        aquamarine.follows = "aquamarine";
        hyprland-guiutils.follows = "hyprland-guiutils";
        pre-commit-hooks.follows = "git-hooks";
      };
    };

    hyprpolkitagent = {
      url = "github:hyprwm/hyprpolkitagent";

      inputs = {
        nixpkgs.follows = "nixpkgs";
        systems.follows = "systems";
        hyprutils.follows = "hyprutils";
        hyprlang.follows = "hyprlang";
        hyprgraphics.follows = "hyprgraphics";
        aquamarine.follows = "aquamarine";
        hyprtoolkit.follows = "hyprtoolkit";
      };
    };

    hyprpaper = {
      url = "github:hyprwm/hyprpaper";

      inputs = {
        nixpkgs.follows = "nixpkgs";
        systems.follows = "systems";
        hyprutils.follows = "hyprutils";
        hyprlang.follows = "hyprlang";
        hyprwayland-scanner.follows = "hyprwayland-scanner";
        hyprwire.follows = "hyprwire";
        hyprgraphics.follows = "hyprgraphics";
        aquamarine.follows = "aquamarine";
        hyprtoolkit.follows = "hyprtoolkit";
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

    # Following main to match hyprland above.
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";

      inputs = {
        nixpkgs.follows = "nixpkgs";
        systems.follows = "systems";
        hyprland.follows = "hyprland";
      };
    };

    # TODO: Maybe remove zed-editor flake
    # NOTE: Building Zed may cause LimitNOFILE error.
    # Build it with:
    # sudo bash -lc 'ulimit -n 1048576; nixos-rebuild switch --option cores 4 --option max-jobs 4'
    # zed-editor = {
    #   url = "github:zed-industries/zed";
    #
    #   inputs = {
    #     nixpkgs.follows = "nixpkgs";
    #     flake-compat.follows = "flake-compat";
    #     rust-overlay.follows = "rust-overlay";
    #   };
    # };

    claude-desktop = {
      url = "github:aaddrick/claude-desktop-debian";

      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
      };
    };

    claude-code = {
      url = "github:sadjow/claude-code-nix";

      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };

    elixir-expert = {
      url = "github:elixir-lang/expert/nightly";

      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
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

    # TODO: Maybe remove zed-editor flake
    # flake-compat.url = "github:NixOS/flake-compat";

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

    hyprwire = {
      url = "github:hyprwm/hyprwire";

      inputs = {
        nixpkgs.follows = "nixpkgs";
        systems.follows = "systems";
        hyprutils.follows = "hyprutils";
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

    aquamarine = {
      url = "github:hyprwm/aquamarine";

      inputs = {
        nixpkgs.follows = "nixpkgs";
        systems.follows = "systems";
        hyprutils.follows = "hyprutils";
        hyprwayland-scanner.follows = "hyprwayland-scanner";
      };
    };

    hyprtoolkit = {
      url = "github:hyprwm/hyprtoolkit";

      inputs = {
        nixpkgs.follows = "nixpkgs";
        systems.follows = "systems";
        hyprutils.follows = "hyprutils";
        hyprlang.follows = "hyprlang";
        hyprwayland-scanner.follows = "hyprwayland-scanner";
        hyprgraphics.follows = "hyprgraphics";
        aquamarine.follows = "aquamarine";
      };
    };

    hyprland-guiutils = {
      url = "github:hyprwm/hyprland-guiutils";

      inputs = {
        nixpkgs.follows = "nixpkgs";
        systems.follows = "systems";
        hyprutils.follows = "hyprutils";
        hyprlang.follows = "hyprlang";
        hyprwayland-scanner.follows = "hyprwayland-scanner";
        hyprgraphics.follows = "hyprgraphics";
        aquamarine.follows = "aquamarine";
        hyprtoolkit.follows = "hyprtoolkit";
      };
    };

    git-hooks = {
      url = "github:cachix/git-hooks.nix";

      inputs = {
        nixpkgs.follows = "nixpkgs";

        # TODO: Maybe remove zed-editor flake
        # flake-compat.follows = "flake-compat";
      };
    };

    # TODO: Maybe remove zed-editor flake
    # rust-overlay = {
    #   url = "github:oxalica/rust-overlay";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
  };

  outputs =
    { self, nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      libs = import ./lib { inherit (nixpkgs) lib; };
      overlays = import ./overlays { inherit inputs system libs; };

      builder = import ./lib/builder.nix {
        inherit (nixpkgs) lib;
        inherit libs;
      };

      mkUser = username: {
        inherit username;
        name = "Muhammad H. Fauzan";
        gitEmail = "14904191+chouzan@users.noreply.github.com";
      };

      user = mkUser "chouzan";

      mkMachine = builder.mkMachineDefaults { inherit inputs system user; };

      # TODO: Introduce `nixosadm` command for unified admin tasks
      # - Similar to `eos` from EndeavourOS
      # - Commit hardware-configuration.nix and stateVersion changes after install
      # - System maintenance, updates, garbage collection
      # - Explore integration with nh (github:nix-community/nh) for better UX
      machines = {
        panthera = mkMachine { };
        neofelis = mkMachine { };
        acinonyx = mkMachine { user = mkUser "muhifauzan"; };

        leopardus = mkMachine {
          homeManager = false;
          aliases = [ "installer" ];
        };

        otocolobus = mkMachine {
          aliases = [ "wsl" ];
        };
      };

      extraModules = with inputs; [
        sops-nix.nixosModules.sops
        quadlet-nix.nixosModules.quadlet
        disko.nixosModules.disko
        stylix.nixosModules.stylix
      ];

      extraHomeManagerModules = with inputs; [
        sops-nix.homeManagerModules.sops
        quadlet-nix.homeManagerModules.quadlet
      ];
    in
    {
      nixosConfigurations =
        builder.buildConfigurations machines extraModules extraHomeManagerModules
          overlays;

      packages.${system} = {
        installer = self.nixosConfigurations.installer.config.system.build.isoImage;
        wsl = self.nixosConfigurations.wsl.config.system.build.tarballBuilder;
      };

      formatter.${system} = inputs.treefmt-nix.lib.mkWrapper pkgs {
        projectRootFile = "flake.nix";
        programs.nixfmt.enable = true;
        settings.global.includes = [ "*.nix" ];
        settings.global.excludes = [ ".knowledge/*" ];
      };
    };
}
