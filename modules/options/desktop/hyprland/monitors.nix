{ config, lib, ... }:

let
  inherit (config.modules) monitors;
  inherit (lib) types;
in
{
  # Extend the base monitors submodule with Hyprland-specific options
  options.modules.monitors = lib.mkOption {
    type = types.listOf (
      types.submodule {
        options.hyprland = lib.mkOption {
          type = types.submodule {
            options = {
              position = lib.mkOption {
                type = types.nullOr types.str;
                default = null;
                example = "auto-center-right";

                description = ''
                  Hyprland-specific position override.
                  When set, this takes precedence over the base position option.

                  Hyprland uses an inverse Y Cartesian system where negative Y values
                  place monitors higher and positive Y values place them lower.
                  Coordinates can be negative (e.g., `"0x-1080"` places monitor above origin).

                  Available Hyprland-specific positioning options:
                  - Coordinates: `"1920x0"`, `"0x-1080"` (relative to other monitors)
                  - `"auto"`: Automatically place to the right of existing monitors
                  - `"auto-left/right/up/down"`: Place in specific direction relative to
                    others, also based on each monitor's top left corner as the root
                  - `"auto-center-right/left/up/down"`: Place in specific direction relative
                    to others, but calculate placement from each monitor's center rather than its top left corner

                  Position is calculated using scaled resolution after transformations.

                  Note: The first monitor will always be positioned at `(0,0)`
                '';
              };

              rotate = lib.mkOption {
                type = types.enum [
                  0
                  1
                  2
                  3
                  4
                  5
                  6
                  7
                ];

                default = 0;

                description = ''
                  Monitor rotation.

                  - `0`: Normal (no transform)
                  - `1`: 90° clockwise
                  - `2`: 180°
                  - `3`: 270° clockwise (90° counter-clockwise)
                  - `4`: Flipped
                  - `5`: Flipped + 90° clockwise
                  - `6`: Flipped + 180°
                  - `7`: Flipped + 270° clockwise (90° counter-clockwise)
                '';
              };

              mirror = lib.mkOption {
                type = types.nullOr types.str;
                default = null;
                example = "eDP-1";
                description = ''Mirror the specified monitor to this monitor (e.g., `"eDP-1"`)'';
              };

              colour = lib.mkOption {
                type = types.enum [
                  "auto"
                  "srgb"
                  "wide"
                  "edid"
                  "hdr"
                  "hdredid"
                ];

                default = "auto";
                example = "wide";

                description = ''
                  Color management presets.

                  ### Options
                  - `"auto"`    : sRGB for 8bpc, wide for 10bpc if supported (recommended)
                  - `"srgb"`    : sRGB primaries (default)
                  - `"wide"`    : Wide color gamut, BT2020 primaries
                  - `"edid"`    : Primaries from edid (known to be inaccurate)
                  - `"hdr"`     : Wide color gamut and HDR PQ transfer function (experimental)
                  - `"hdredid"` : Same as hdr with edid primaries (experimental)
                '';
              };

              vrr = lib.mkOption {
                type = types.enum [
                  0
                  1
                  2
                  3
                ];

                default = 0;

                description = ''
                  Variable Refresh Rate (VRR) setting.

                  - `0`: Off
                  - `1`: On
                  - `2`: Fullscreen only
                  - `3`: Fullscreen with `video` or `game` content type
                '';
              };

              workspace = lib.mkOption {
                type = types.nullOr types.str;
                default = null;
                example = "1";

                description = ''
                  Default workspace to assign to this monitor.

                  Maps to Hyprland's workspace assignment for monitors.
                  Examples: `"1"`, `"main"`, `"web"`, `"dev"`
                '';
              };
            };
          };

          default = { };
          description = "Hyprland-specific monitor options";
        };
      }
    );
  };

  config.assertions =
    lib.optionals ((lib.length monitors) != 0 && lib.any (m: m ? hyprland) monitors)
      [
        (
          let
            monitorsWithMirror = lib.filter (m: m.hyprland.mirror != null) monitors;
            invalidMirrors = lib.filter (
              m: !lib.any (reference: m.hyprland.mirror == reference.name) monitors
            ) monitorsWithMirror;
          in
          {
            assertion = (lib.length invalidMirrors) == 0;
            message = ''
              Monitor mirror targets must reference existing monitors.

              Invalid mirror configurations: ${
                toString (map (m: "${m.name} -> ${m.hyprland.mirror}") invalidMirrors)
              }
            '';
          }
        )
      ];
}
