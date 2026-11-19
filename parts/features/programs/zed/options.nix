{
  flake.modules.nixos.programs-zed = { lib, ... }: {
    options.modules.programs.zed.enable =
      lib.mkEnableOption "Zed code editor (program name: zed-editor)";
  };
}
