{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config.modules) packages;
  cfg = config.modules.hardware;
in
{
  hardware.graphics = {
    extraPackages = with pkgs; [
      # VA-API (Video Acceleration API)
      libva

      # VDPAU driver with OpenGL/VA-API backend
      libvdpau-va-gl

      # VDPAU to VA-API bridge (fallback)
      libva-vdpau-driver
    ];

    extraPackages32 = with pkgs.pkgsi686Linux; [
      libva
      libvdpau-va-gl
      libva-vdpau-driver
    ];
  };

  environment = {
    # VA-API utilities, vainfo, vaapi-fits
    systemPackages = lib.optionals packages.admin.enable [ pkgs.libva-utils ];

    sessionVariables = lib.mkMerge [
      {
        # Enable MPEG-4 Part 2 for VA-API
        # Warning: VA-API has limitations with this feature
        # VAAPI_MPEG4_ENABLED = true;
      }

      (lib.mkIf cfg.gpu.amd.enable {
        # Force-enable Vulkan Video support for older AMD GPU cards
        # RADV_PERFTEST = "video_decode,video_encode";

        # VA-API driver for AMD GPU driver
        LIBVA_DRIVER_NAME = "radeonsi";

        # VDPAU driver for AMD GPU driver
        VDPAU_DRIVER = "radeonsi";
      })
    ];
  };
}
