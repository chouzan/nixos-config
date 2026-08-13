_final: prev:

let
  # The check runs inside the derivation of the script it checks, where only the
  # inputs of that derivation are on PATH, so the checker carries Nushell with
  # it for the process it starts.
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
  # `writers.writeNu` accepts a `check` argument and leaves it empty, so a parse
  # error surfaces only when the script runs. `writeNuChecked` and
  # `writeNuBinChecked` fill that argument in, which moves the failure to build
  # time. Every other argument, including `makeWrapperArgs`, passes through
  # untouched.
  #
  # The checker itself is written with the unchecked builder, because a builder
  # that checked it would need it in order to build.
  writeNuChecked =
    name: arguments: content:
    prev.writers.writeNu name ({ check = nuCheck; } // arguments) content;

  writeNuBinChecked =
    name: arguments: content:
    prev.writers.writeNuBin name ({ check = nuCheck; } // arguments) content;
}
