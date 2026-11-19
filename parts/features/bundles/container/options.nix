{
  flake.modules.nixos.bundles-container = { lib, ... }: {
    options.modules.bundles.container.enable =
      lib.mkEnableOption "container and virtualization tools (podman, podman-compose)";
  };
}
