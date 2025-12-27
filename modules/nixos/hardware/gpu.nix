{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config) modules;
  cfg = modules.hardware;
in
{
  config = lib.mkIf cfg.gpu.amd.enable {
    hardware.amdgpu = {
      # Load AMD kernel module in stage 1
      # Can fix lower resolution in boot screen during initramfs
      initrd.enable = true;

      # OpenCL support via ROCm
      opencl.enable = true;
    };

    environment = {
      # AMD GPU utilities, amdgpu_top
      systemPackages = lib.optionals modules.packages.admin.enable [ pkgs.amdgpu_top ];

      # Force use Mesa RADV if there's a performance issues (e.g. <50% less FPS in games)
      # sessionVariables.AMD_VULKAN_ICD = "RADV";
    };
  };
}
