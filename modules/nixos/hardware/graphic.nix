{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config.modules) packages;
in
{
  # Enable OpenGL, Vulkan (Mesa RADV), and other graphics drivers/libraries for GPU acceleration
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  environment.systemPackages =
    with pkgs;
    lib.optionals packages.admin.enable [
      # Mesa utilities, glxinfo, glxgears, es2_info, es2gears
      mesa-demos

      # Vulkan utilities, vulkaninfo, vkcube, vkcubepp
      vulkan-tools
    ];
}
