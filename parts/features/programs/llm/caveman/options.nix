{
  flake.modules.nixos.programs-llm-caveman = { lib, ... }: {
    options.modules.programs.llm.plugins.caveman.enable =
      lib.mkEnableOption "Caveman workflow plugin for LLM coding agents";
  };
}
