{
  osConfig,
  lib,
  pkgs,
  ...
}:

let
  inherit (osConfig) modules;
  cfg = modules.desktop.hyprland;
  stylixFonts = osConfig.stylix.fonts;

  # Templated below via replaceVars; excluded from the plain-copy set.
  templatedQml = [
    "config/Config.qml"
    "config/Theme.qml"
  ];

  # Auto-discover every other component, at any depth, as a path relative to
  # ./qml — drop a .qml anywhere under it and it ships to the same place.
  collectQml =
    dir: prefix:
    lib.concatLists (
      lib.mapAttrsToList (
        name: type:
        let
          relative = if prefix == "" then name else "${prefix}/${name}";
        in
        if type == "directory" then
          collectQml (dir + "/${name}") relative
        else
          lib.optional (lib.hasSuffix ".qml" name) relative
      ) (builtins.readDir dir)
    );

  qmlFiles = lib.subtractLists templatedQml (collectQml ./qml "");

  qmlPath = name: ./qml + "/${name}";

  # A singleton is only visible to another directory through a qmldir. A qmldir
  # covers one directory and *replaces* the file scan for it, so it has to name
  # every type there, not just the singletons, or the rest become invisible.
  # Generated rather than checked in, so it cannot drift from the sources, and
  # over the templated files too, since those are singletons as well.
  allQml = qmlFiles ++ templatedQml;

  qmlByDir = lib.groupBy dirOf allQml;

  dirsWithSingleton = lib.filterAttrs (
    _: names: lib.any (name: lib.hasInfix "pragma Singleton" (builtins.readFile (qmlPath name))) names
  ) qmlByDir;

  mkQmldirEntry = dir: names: {
    name = "quickshell/bar/${dir}/qmldir";
    value.text = lib.concatMapStrings (
      name:
      let
        type = lib.removeSuffix ".qml" (baseNameOf name);
        singleton = lib.hasInfix "pragma Singleton" (builtins.readFile (qmlPath name));
      in
      (if singleton then "singleton " else "") + "${type} 1.0 ${type}.qml\n"
    ) names;
  };

  mkQmlEntry = name: {
    name = "quickshell/bar/${name}";
    value.source = qmlPath name;
  };

  configQml = pkgs.replaceVars ./qml/config/Config.qml {
    fontFamily = stylixFonts.sansSerif.name;
    fontFamilyMono = stylixFonts.monospace.name;
    fontSizeBase = toString stylixFonts.sizes.desktop;
    whereAmI = "${pkgs.geoclue2}/libexec/geoclue-2.0/demos/where-am-i";
  };

  themeQml =
    let
      colours = osConfig.lib.stylix.colors.withHashtag;
    in
    pkgs.replaceVars ./qml/config/Theme.qml {
      inherit (colours)
        base00
        base01
        base02
        base03
        base04
        base05
        base06
        base07
        base08
        base09
        base0A
        base0B
        base0C
        base0D
        base0E
        base0F
        ;
    };

  # Fail at eval time if QML references an icon not present in assets/icons/
  referencedIcons = lib.unique (
    lib.concatMap (token: if builtins.isList token then token else [ ]) (
      builtins.split "\"([^\"]+\\.svg)\"" (
        lib.concatMapStrings (name: builtins.readFile (qmlPath name)) qmlFiles
      )
    )
  );
  availableIcons = builtins.attrNames (builtins.readDir ./assets/icons);
  missingIcons = lib.subtractLists availableIcons referencedIcons;
in
{
  config = lib.mkIf cfg.enable (
    assert lib.assertMsg (
      missingIcons == [ ]
    ) "Quickshell QML references missing SVG icons: ${lib.concatStringsSep ", " missingIcons}";
    {
      home.packages = [
        pkgs.quickshell
        pkgs.pulseaudio
      ];

      xdg.configFile =
        builtins.listToAttrs (map mkQmlEntry qmlFiles)
        // builtins.listToAttrs (lib.mapAttrsToList mkQmldirEntry dirsWithSingleton)
        // builtins.listToAttrs (
          map (name: {
            name = "quickshell/bar/assets/icons/${name}";
            value.source = ./assets/icons/${name};
          }) (builtins.attrNames (builtins.readDir ./assets/icons))
        )
        // {
          "quickshell/bar/config/Config.qml".source = configQml;
          "quickshell/bar/config/Theme.qml".source = themeQml;
        };

      systemd.user.services.quickshell-bar = {
        Unit = {
          Description = "Quickshell bar";
          PartOf = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
        };

        Service = {
          ExecStart = "${pkgs.quickshell}/bin/quickshell -c bar";
          Restart = "on-failure";
          RestartSec = 1;
          Environment = [
            "QS_CONFIG_HASH=${builtins.hashString "sha256" (toString (map qmlPath qmlFiles))}"
          ];
        };

        Install = {
          WantedBy = [ "graphical-session.target" ];
        };
      };
    }
  );
}
