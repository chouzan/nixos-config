{
  flake.modules.nixos.programs-carapace = { lib, ... }: {
    options.modules.programs.carapace.enable =
      lib.mkEnableOption "Carapace multi-shell command argument completer";
  };
}
