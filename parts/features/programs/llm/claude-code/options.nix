{
  flake.modules.nixos.programs-llm-claude-code = { lib, pkgs, ... }: {
    options.modules.programs.llm.claude-code = {
      enable = lib.mkEnableOption "Claude Code agentic coding tool";

      systemSettings = lib.mkOption {
        inherit (pkgs.formats.json { }) type;
        default = { };
        internal = true;
        description = "Composable policy for the Claude Code managed settings layer";
      };

      userSettings = lib.mkOption {
        inherit (pkgs.formats.json { }) type;
        default = { };
        internal = true;
        description = "Composable preferences merged into the writable Claude Code user settings";
      };

      statusLineSegments = lib.mkOption {
        type = lib.types.listOf (
          lib.types.submodule {
            options = {
              order = lib.mkOption {
                type = lib.types.int;
                default = 100;
                description = "Sort key. A lower value puts the segment further left.";
              };

              command = lib.mkOption {
                type = lib.types.str;
                description = "Command that reads the status payload on stdin and writes one segment.";
              };
            };
          }
        );

        default = [ ];
        internal = true;
        description = "Composable segments for the Claude Code status line";
      };
    };
  };
}
