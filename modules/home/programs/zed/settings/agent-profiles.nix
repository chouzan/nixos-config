{
  osConfig,
  lib,
  libs,
  ...
}:

let
  inherit (libs.mcp) servers;
  cfg = osConfig.modules.programs.zed;
in
{
  config = lib.mkIf cfg.enable {
    programs.zed-editor.userSettings.agent = {
      default_profile = "write";

      profiles = {
        write = {
          name = "Write";

          tools = {
            thinking = true;
            list_directory = true;
            find_path = true;
            grep = true;
            read_file = true;
            web_search = true;
            fetch = true;
            open = true;
            diagnostics = true;
            now = true;

            create_directory = true;
            move_path = true;
            copy_path = true;
            edit_file = true;
            delete_path = true;
            terminal = true;
          };

          context_servers = {
            "${servers.sequential-thinking.name}".tools.sequentialthinking = true;

            "${servers.context7.name}".tools = {
              resolve-library-id = true;
              query-docs = true;
            };
          };
        };

        ask = {
          name = "Ask";

          tools = {
            thinking = true;
            list_directory = true;
            find_path = true;
            grep = true;
            read_file = true;
            web_search = true;
            fetch = true;
            open = true;
            diagnostics = true;
            now = true;
          };

          context_servers = {
            "${servers.sequential-thinking.name}".tools.sequentialthinking = true;

            "${servers.context7.name}".tools = {
              resolve-library-id = true;
              query-docs = true;
            };
          };
        };

        minimal = {
          name = "Minimal";
          tools = { };
          context_servers = { };
        };
      };
    };
  };
}
