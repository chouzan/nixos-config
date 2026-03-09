# Pin less to 685 to work around kitty keyboard protocol bug
# in search mode (no input captured when TERM=xterm-kitty).
# Reportedly fixed in less 692.
# See: https://github.com/gwsw/less/issues/710
{ inputs, system }:

let
  upstream = inputs.nixpkgs.legacyPackages.${system}.less.version;
in

_: prev:

if prev.lib.versionAtLeast upstream "692" then
  builtins.trace "warning: less: upstream is ${upstream} (>=692). Remove overlays/less.nix" { }
else
  {
    less = prev.less.overrideAttrs (_: rec {
      version = "685";

      src = prev.fetchurl {
        url = "https://www.greenwoodsoftware.com/less/less-${version}.tar.gz";
        hash = "sha256-JwEEHnZ+aX7kIM4IJWQc7cjyC1FXar6Z2SwWZtMy6dw=";
      };
    });
  }
