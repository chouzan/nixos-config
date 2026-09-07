_final: prev:

let
  # The check runs inside the derivation it checks, where only that
  # derivation's inputs are on PATH, so the checker carries Nushell itself.
  #
  # It is built with the unchecked writer, since a checking one would need this
  # checker to build.
  nuCheck = prev.writers.writeNu "nu-ide-check" {
    makeWrapperArgs = [
      "--prefix"
      "PATH"
      ":"
      "${prev.lib.makeBinPath [ prev.nushell ]}"
    ];
  } ./nu-ide-check.nu;
in
{
  # The checker as a package, for a build that runs the gate itself. It takes
  # one file per run.
  nu-ide-check = nuCheck;

  # `writers.writeNu` leaves its `check` argument empty, so a parse error
  # surfaces only at run time. These fill it in, moving the failure to the
  # build.
  writeNuChecked =
    name: arguments: content:
    prev.writers.writeNu name ({ check = nuCheck; } // arguments) content;

  writeNuBinChecked =
    name: arguments: content:
    prev.writers.writeNuBin name ({ check = nuCheck; } // arguments) content;
}
