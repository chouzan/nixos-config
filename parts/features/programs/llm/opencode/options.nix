{
  flake.modules.nixos.programs-llm-opencode = { lib, ... }: {
    options.modules.programs.llm.opencode.enable = lib.mkEnableOption "OpenCode agentic coding tool";
  };
}
