{ lib, libs }:

let
  defaultMachine = {
    # Required
    system = null;
    user = null;
    inputs = null;

    # Resolved from machine name
    configDir = null;
    nixosConfig = null;
    homeManagerConfig = null;

    # Optional
    homeManager = true;
    aliases = [ ];
  };

  mkMachineDefaults = defaults: overrides: defaultMachine // defaults // overrides;

  buildConfiguration =
    {
      system,
      hostName,
      user,
      nixosConfig,
      inputs,
      homeManagerConfig,
      extraModules,
      extraHomeManagerModules,
      overlays ? [ ],
    }:
    let
      machine = { inherit hostName user; };
    in
    lib.nixosSystem {
      specialArgs = { inherit inputs machine libs; };

      modules = [
        inputs.nur.modules.nixos.default
        nixosConfig

        {
          nixpkgs = {
            inherit overlays;
            hostPlatform = system;
          };
        }

        (lib.optionalAttrs (homeManagerConfig != null) {
          imports = [ inputs.home-manager.nixosModules.home-manager ];

          home-manager = {
            backupFileExtension = "bak";
            useGlobalPkgs = true;
            useUserPackages = true;
            extraSpecialArgs = { inherit machine inputs libs; };

            users.${user.username} = {
              imports = [ homeManagerConfig ] ++ extraHomeManagerModules;
            };
          };
        })
      ]
      ++ extraModules;
    };

  resolveConfig =
    name: machine:
    let
      hostName = name;

      configDir =
        if lib.isPath machine.configDir then
          machine.configDir
        else if lib.isString machine.configDir then
          ../hosts/${machine.configDir}
        else
          ../hosts/${hostName};

      nixosConfig =
        if machine.nixosConfig != null then machine.nixosConfig else configDir + "/configuration.nix";

      homeManagerConfig =
        if !machine.homeManager then
          null
        else if machine.homeManagerConfig != null then
          machine.homeManagerConfig
        else
          configDir + "/home.nix";
    in
    machine
    // {
      inherit
        hostName
        configDir
        nixosConfig
        homeManagerConfig
        ;
    };

  collectNames =
    machineConfigs:
    lib.foldlAttrs (
      acc: _name: machine:
      acc ++ [ machine.hostName ] ++ machine.aliases
    ) [ ] machineConfigs;

  findConfigForName =
    machineConfigs: configs: name:
    let
      matchName = lib.findFirst (
        key: machineConfigs.${key}.hostName == name || lib.elem name machineConfigs.${key}.aliases
      ) null (lib.attrNames machineConfigs);
    in
    configs.${matchName};

  buildConfigurations =
    machines: extraModules: extraHomeManagerModules: overlays:
    let
      machineConfigs = lib.mapAttrs resolveConfig machines;

      configs = lib.mapAttrs (
        _name: machine:
        buildConfiguration {
          inherit extraModules extraHomeManagerModules overlays;

          inherit (machine)
            system
            hostName
            user
            nixosConfig
            homeManagerConfig
            inputs
            ;
        }
      ) machineConfigs;

      names = collectNames machineConfigs;
      namedConfigs = lib.genAttrs names (findConfigForName machineConfigs configs);
    in
    configs // namedConfigs;
in
{
  inherit
    buildConfigurations
    mkMachineDefaults
    ;
}
