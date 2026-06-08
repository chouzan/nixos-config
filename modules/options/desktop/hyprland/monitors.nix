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

                  Available positioning options:
                  - Coordinates: `"1920x0"`, `"0x-1080"` (relative to other monitors)
                  - `"auto"`: Place to the right of existing monitors
                  - `"auto-left/right/up/down"`: Place in a specific direction,
                    using each monitor's top left corner as the root
                  - `"auto-center-right/left/up/down"`: Place in a specific direction,
                    using each monitor's center as the root

                  Position is calculated using scaled resolution after transformations.
                  The first monitor is always positioned at `(0,0)`.
                '';
              };

              transform = lib.mkOption {
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
                  Monitor rotation and flip transform.

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

                description = ''
                  Mirror the specified monitor to this monitor.

                  Mirroring does not re-render at the target's resolution;
                  aspect ratio differences will cause stretching.
                '';
              };

              bitdepth = lib.mkOption {
                type = types.enum [
                  8
                  10
                ];

                default = 8;

                description = ''
                  Color bit depth per channel.

                  - `8` : Standard 8-bit (XRGB8888)
                  - `10`: 10-bit (XRGB2101010) -- smoother gradients, less banding

                  Note: Border colors and some screen capture tools do not support 10-bit.
                '';
              };

              cm = lib.mkOption {
                type = types.enum [
                  "srgb"
                  "auto"
                  "dcip3"
                  "dp3"
                  "adobe"
                  "wide"
                  "edid"
                  "hdr"
                  "hdredid"
                ];

                default = "srgb";
                example = "wide";

                description = ''
                  Color management preset.

                  - `"srgb"`    : sRGB primaries (default)
                  - `"auto"`    : sRGB for 8bpc, wide for 10bpc if supported
                  - `"dcip3"`   : DCI P3 primaries
                  - `"dp3"`     : Apple Display P3 primaries
                  - `"adobe"`   : Adobe RGB primaries
                  - `"wide"`    : Wide color gamut, BT2020 primaries
                  - `"edid"`    : Primaries from EDID (known to be inaccurate)
                  - `"hdr"`     : Wide gamut + HDR PQ transfer function (experimental)
                  - `"hdredid"` : Same as `"hdr"` with EDID primaries (experimental)

                  Fullscreen HDR is possible without `"hdr"` if `render:cm_auto_hdr` is enabled.
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
                  Variable Refresh Rate (VRR).

                  - `0`: Off
                  - `1`: On
                  - `2`: Fullscreen only
                  - `3`: Fullscreen with `video` or `game` content type
                '';
              };

              workspace = lib.mkOption {
                type = types.nullOr types.str;
                default = null;
                example = "primary";

                description = ''
                  Default workspace to assign to this monitor.
                  Examples: `"1"`, `"primary"`, `"web"`, `"dev"`
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
