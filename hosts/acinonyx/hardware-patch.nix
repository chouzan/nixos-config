{ lib, pkgs, ... }:

{
  boot = {
    blacklistedKernelModules = [
      "nouveau"
      "nvidia"
      "nvidia_drm"
      "nvidia_modeset"
      "i915"
    ];

    kernelParams = [
      "i915.modeset=0"
    ];

    extraModprobeConfig = ''
      blacklist nouveau
      options nouveau modeset=0
    '';

    initrd.prepend = lib.mkOrder 0 [
      "${pkgs.fetchurl {
        url = "https://gitlab.freedesktop.org/drm/amd/uploads/9fe228c7aa403b78c61fb1e29b3b35e3/slim7-ssdt";
        sha256 = "sha256-Ef4QTxdjt33OJEPLAPEChvvSIXx3Wd/10RGvLfG5JUs=";
        name = "slim7-ssdt";
      }}"
    ];
  };

  services.udev.extraRules = ''
    # Remove NVIDIA USB xHCI Host Controller devices, if present
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c0330", ATTR{power/control}="auto", ATTR{remove}="1"

    # Remove NVIDIA USB Type-C UCSI devices, if present
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c8000", ATTR{power/control}="auto", ATTR{remove}="1"

    # Remove NVIDIA Audio devices, if present
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x040300", ATTR{power/control}="auto", ATTR{remove}="1"

    # Remove NVIDIA VGA/3D controller devices
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x03[0-9]*", ATTR{power/control}="auto", ATTR{remove}="1"
  '';
}
