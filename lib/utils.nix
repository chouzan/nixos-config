{ lib }:

let
  defaultMachine = {
    # Required
    system = null;
    user = null;
    inputs = null;

    # Auto-resolved
    hostname = null;
    configDir = null;
    nixosConfig = null;
    # TODO: Refactor to explicit boolean (default false, require explicit true)
    # Remove auto-detect magic - user should explicitly enable homeManager
    homeManager = null; # null = auto-detect, true = force enable, false = force disable
    homeManagerConfig = null;

    # Optional
    aliases = [ ];
  };

  mkMachineDefaults = defaults: overrides: defaultMachine // defaults // overrides;

  validateMachines =
    machines:
    let
      collectNames =
        name: machine:
        let
          inherit (machine) hostname aliases;

          mkRecord = recordName: source: {
            inherit hostname source;

            name = recordName;
            machine = name;
          };

        in
        [ (mkRecord name "primary") ]
        ++ lib.optional (hostname != null && hostname != name) (mkRecord hostname "hostname")
        ++ lib.map (alias: mkRecord alias "alias") aliases;

      allNameSources = lib.flatten (lib.mapAttrsToList collectNames machines);
      nameGroups = builtins.groupBy (item: item.name) allNameSources;
      conflicts = lib.filterAttrs (_name: items: lib.length items > 1) nameGroups;

      formatConflict =
        name: items:
        let
          sources = lib.map (
            item: "${item.machine} (hostname: ${item.hostname}, source: ${item.source})"
          ) items;
        in
        "Name '${name}' conflicts between: ${lib.concatStringsSep ", " sources}";

      conflictMessages = lib.mapAttrsToList formatConflict conflicts;
    in
    if conflicts == { } then
      true
    else
      throw "Machine configuration conflicts:\n${lib.concatStringsSep "\n" conflictMessages}";

  buildConfiguration =
    {
      system,
      hostname,
      user,
      nixosConfig,
      inputs,
      homeManagerConfig,
      extraModules,
      extraHomeManagerModules,
      overlays ? [ ],
    }:
    let
      machine = { inherit hostname user; };
      libs = import ./. { inherit lib; };
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

  collectAllNames =
    machineConfigs:
    lib.foldlAttrs
      (acc: name: machine: {
        names = acc.names ++ [ name ];
        hostnames = acc.hostnames ++ [ machine.hostname ];
        aliases = acc.aliases ++ machine.aliases;
        allAliases = acc.allAliases ++ [ machine.hostname ] ++ machine.aliases;
      })
      {
        names = [ ];
        hostnames = [ ];
        aliases = [ ];
        allAliases = [ ];
      }
      machineConfigs;

  resolveMachineConfigs =
    machines: lib.mapAttrs (_: resolved: resolved.machine) (autoResolveConfigurations machines);

  buildConfigurations =
    machines: extraModules: extraHomeManagerModules: overlays:
    let
      machineConfigs = resolveMachineConfigs machines;

      configs = lib.mapAttrs (
        _name: machine:
        buildConfiguration {
          inherit extraModules extraHomeManagerModules overlays;

          inherit (machine)
            system
            hostname
            user
            nixosConfig
            homeManagerConfig
            inputs
            ;
        }
      ) machineConfigs;

      nameCollections = collectAllNames machineConfigs;
      aliases = nameCollections.allAliases;

      findConfigForAlias =
        alias:
        let
          matchName = lib.findFirst (
            name: machineConfigs.${name}.hostname == alias || lib.elem alias machineConfigs.${name}.aliases
          ) null (lib.attrNames machineConfigs);
        in
        configs.${matchName};

      aliasConfigs = lib.genAttrs aliases findConfigForAlias;

    in
    configs // aliasConfigs;

  mkResolver =
    key: resolverFn:
    { machine, autoResolve }:
    let
      resolved = resolverFn machine;
    in
    {
      machine = machine // {
        ${key} = resolved.value;
      };

      autoResolve = autoResolve // {
        ${key} = resolved.isAuto;
      };
    };

  autoResolveConfigurations = machines: lib.mapAttrs autoResolveMachine machines;

  autoResolveMachine =
    name: machine:
    lib.pipe (autoResolveHostname name machine) [
      autoResolveConfigDir
      autoResolveNixosConfig
      autoResolveHomeManagerConfig
    ];

  autoResolveHostname =
    name: machine:
    let
      resolved =
        if machine.hostname != null then
          {
            value = machine.hostname;
            isAuto = false;
          }
        else
          {
            value = name;
            isAuto = true;
          };
    in
    {
      machine = machine // {
        hostname = resolved.value;
      };

      autoResolve = {
        hostname = resolved.isAuto;
      };
    };

  autoResolveConfigDir = mkResolver "configDir" (
    machine:
    if lib.isPath machine.configDir then
      {
        value = machine.configDir;
        isAuto = false;
      }
    else if lib.isString machine.configDir then
      {
        value = ../hosts/${machine.configDir};
        isAuto = true;
      }
    else if lib.pathExists (../hosts + "/${machine.hostname}") then
      {
        value = ../hosts/${machine.hostname};
        isAuto = true;
      }
    else
      {
        value = ../hosts/default;
        isAuto = true;
      }
  );

  autoResolveNixosConfig = mkResolver "nixosConfig" (
    machine:
    if machine.nixosConfig != null then
      {
        value = machine.nixosConfig;
        isAuto = false;
      }
    else
      {
        value = machine.configDir + "/configuration.nix";
        isAuto = true;
      }
  );

  # TODO: Reconsider home.nix auto-resolution magic
  # Current behavior auto-detects home.nix per host, but most hosts share similar config
  # Options:
  # - Introduce hosts/shared/home.nix for common home-manager config
  # - Use profiles/home/base.nix following profile pattern
  # - Require explicit homeManagerConfig paths instead of magic
  # See also: flake.nix TODOs for hosts/shared/ discussion
  autoResolveHomeManagerConfig = mkResolver "homeManagerConfig" (
    machine:
    # Three-state logic:
    # - false: explicitly disabled
    # - true: explicitly enabled (use home.nix)
    # - null: auto-detect (enable only if home.nix exists)
    if machine.homeManager == false then
      {
        value = null;
        isAuto = false;
      }
    else if machine.homeManagerConfig != null then
      {
        value = machine.homeManagerConfig;
        isAuto = false;
      }
    else if machine.homeManager == true || lib.pathExists (machine.configDir + "/home.nix") then
      {
        value = machine.configDir + "/home.nix";
        isAuto = true;
      }
    else
      {
        value = null;
        isAuto = false;
      }
  );

  showConfigurations =
    machines:
    let
      resolvedConfigs = autoResolveConfigurations machines;
      machineConfigs = resolveMachineConfigs machines;

      nameCollections = collectAllNames machineConfigs;

      inherit (nameCollections)
        names
        hostnames
        aliases
        ;

      pathInfo = lib.mapAttrs (
        _name: resolved:
        let
          inherit (resolved) autoResolve;

          machine = {
            inherit (resolved.machine)
              hostname
              nixosConfig
              homeManagerConfig
              configDir
              ;
          };
        in
        {
          inherit autoResolve machine;
        }
      ) resolvedConfigs;
    in
    {
      inherit
        aliases
        hostnames
        names
        pathInfo
        ;

      totalNames = lib.length (names ++ nameCollections.allAliases);
    };

  getEnabledMonitors = monitors: lib.filter (m: !m.disabled) monitors;

  # Returns value unless it's exactly false (allows null and other falsy values)
  orUnless = fallback: value: if value != false then value else fallback;
  orIfNull = fallback: value: if value != null then value else fallback;
  orIfEmpty = fallback: value: if value != [ ] then value else fallback;

  # Priority hierarchy:
  # - mkOptionDefault(1500)
  # - * mkModuleDefault(1450)
  # - * mkProfileDefault(1350)
  # - mkDefault(1000)
  # - mkForce(50)
  mkModuleDefault = lib.mkOverride 1450;
  mkProfileDefault = lib.mkOverride 1350;

  withNormalization = f: machines: f (lib.mapAttrs (_: machine: defaultMachine // machine) machines);

  test = {
    validateMachines = withNormalization validateMachines;
    showConfigurations = withNormalization showConfigurations;
  };
in
{
  inherit
    buildConfigurations
    getEnabledMonitors
    mkMachineDefaults
    mkModuleDefault
    mkProfileDefault
    orUnless
    orIfNull
    orIfEmpty
    test
    ;
}
