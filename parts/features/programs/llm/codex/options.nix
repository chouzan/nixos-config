{
  flake.modules.nixos.programs-llm-codex = { lib, pkgs, ... }: {
    options.modules.programs.llm.codex = {
      enable = lib.mkEnableOption "Codex CLI agentic coding tool";

      systemSettings = lib.mkOption {
        inherit (pkgs.formats.toml { }) type;
        default = { };
        internal = true;
        description = "Composable settings for the Codex System configuration layer";
      };
    };
  };
}
