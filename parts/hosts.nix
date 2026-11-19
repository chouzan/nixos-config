{ inputs, config, ... }:

let
  inherit (inputs) nixpkgs;
  inherit (nixpkgs) lib;

  system = "x86_64-linux";
  libs = import ../lib { inherit (nixpkgs) lib; };
  overlays = import ../overlays { inherit inputs system libs; };

  builder = import ../lib/builder.nix {
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

  # TODO: Extend `nixosadm` beyond firmware boot entries
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

  extraModules =
    with inputs;
    [
      (import-tree [
        ../modules/options
        ../modules/nixos
      ])

      sops-nix.nixosModules.sops
      nix-index-database.nixosModules.default
      quadlet-nix.nixosModules.quadlet
      disko.nixosModules.disko
      stylix.nixosModules.stylix
    ]
    ++ lib.attrValues config.flake.modules.nixos;

  extraHomeManagerModules =
    with inputs;
    [
      (import-tree ../modules/home)

      sops-nix.homeManagerModules.sops
      quadlet-nix.homeManagerModules.quadlet
    ]
    ++ lib.attrValues config.flake.modules.homeManager;
in
{
  flake.nixosConfigurations =
    builder.buildConfigurations machines extraModules extraHomeManagerModules
      overlays;
}
