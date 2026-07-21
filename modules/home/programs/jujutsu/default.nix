{
  osConfig,
  lib,
  pkgs,
  machine,
  ...
}:

let
  inherit (machine) user;
  cfg = osConfig.modules.programs.jujutsu;
in
{
  imports = [
    ./aliases.nix
  ];

  config = lib.mkIf cfg.enable {
    programs.jujutsu = {
      enable = true;

      settings = {
        user = {
          inherit (user) name;
          email = user.gitEmail;
        };

        # jj deliberately refuses to read config stored inside a repository --
        # a tracked config could run arbitrary commands via `fix.tools` on
        # clone -- so repo-specific settings belong here, narrowed with
        # `--when.repositories` instead of applying to every repo.
        #
        # `jj fix` reformats every mutable commit in the stack, not just the
        # working copy, so formatting lands in the commit that introduced the
        # code instead of a trailing fixup commit. Mirrors the treefmt/nixfmt
        # formatter in flake.nix. Tools read stdin and write stdout; nixfmt
        # needs an explicit `-` for that since 1.4.0 deprecated bare stdin.
        "--scope" = [
          {
            "--when".repositories = [ "/etc/nixos" ];

            fix.tools.nixfmt = {
              command = [
                (lib.getExe pkgs.nixfmt)
                "-"
              ];

              patterns = [ "glob:**/*.nix" ];
            };
          }
        ];
      };
    };
  };
}
