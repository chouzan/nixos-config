# TODO: WORKAROUND:BEGIN alsa-ucm-conf#773 — remove when nixpkgs ships
# alsa-ucm-conf >= 1.2.16.1 (nixpkgs PR #536198). Removal means deleting both
# marked regions in this file and restoring the header to `{ ... }:`.
{ pkgs, ... }:

let
  # alsa-ucm-conf 1.2.16 regressed the Realtek ALC4080 UCM profile: the S/PDIF
  # presence probe searches the PCM `subname` field for "Audio #3", but that
  # string lives in the `name` field. The probe finds nothing, the S/PDIF device
  # is dropped, and the optical output disappears on the MSI X870 Tomahawk
  # (0db0:cd0e) and similar ALC4080 boards. Fixed upstream in 1.2.16.1;
  # nixpkgs carries the bump on master but it has not reached the channel yet.
  #
  # Patch the UCM tree here instead of overriding alsa-ucm-conf itself: alsa-lib
  # takes that package as a build input, so overriding it invalidates the binary
  # cache for every audio-capable package in the closure.
  ucm2 =
    if builtins.compareVersions pkgs.alsa-ucm-conf.version "1.2.16" > 0 then
      builtins.warn "alsa-ucm-conf: >1.2.16 detected. Remove the ALC4080 S/PDIF UCM override in modules/nixos/hardware/audio.nix." "${pkgs.alsa-ucm-conf}/share/alsa/ucm2"
    else
      pkgs.runCommand "alsa-ucm-conf-alc4080-spdif-fix" { } ''
        cp -r ${pkgs.alsa-ucm-conf}/share/alsa/ucm2 $out
        chmod -R u+w $out
        substituteInPlace $out/USB-Audio/Realtek/ALC4080-HiFi.conf \
          --replace-fail "field=subname,regex='Audio #3'" "field=name,regex='Audio #3'"
      '';
in
# TODO: WORKAROUND:END alsa-ucm-conf#773
{
  services.pipewire = {
    enable = true;
    audio.enable = true;
    pulse.enable = true;
    wireplumber.enable = true;

    alsa = {
      enable = true;
      support32Bit = true;
    };
  };

  # TODO: WORKAROUND:BEGIN alsa-ucm-conf#773
  # PipeWire and WirePlumber run as systemd user services, which read their
  # environment from environment.d via systemd-environment-d-generator.
  environment.etc."environment.d/50-alsa-ucm-alc4080-spdif-fix.conf".text = ''
    ALSA_CONFIG_UCM2=${ucm2}
  '';
  # TODO: WORKAROUND:END alsa-ucm-conf#773
}
