{ ... }:

{
  projectRootFile = "flake.nix";
  programs.nixfmt.enable = true;

  # Disabled until nufmt handles records reliably. It strips trailing commas
  # from records it parses and inserts them, with trailing whitespace, into
  # records it fails to parse, so no way of writing a record survives a run.
  # It also deletes code it cannot parse and still exits 0.
  #
  # settings = {
  #   formatter.nufmt = {
  #     command = lib.getExe pkgs.nufmt;
  #
  #     options = [
  #       "--config"
  #       "${./nufmt.nuon}"
  #     ];
  #
  #     includes = [ "*.nu" ];
  #   };
  # };
}
