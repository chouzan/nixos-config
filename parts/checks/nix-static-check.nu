# Static analysis of the Nix files of this configuration.
#
# statix and deadnix report through the exit status, so a failure of either one
# stops the script. nixf-tidy carries the rules that an editor shows through
# nixd, which the other two tools do not have. It writes findings as JSON and
# keeps the exit status for the failure of the tool itself.

def collect-diagnostics [nix_file: path]: nothing -> table {
  open --raw $nix_file
  | ^nixf-tidy --variable-lookup
  | from json --strict
  | each {|diagnostic|
    # A message holds one `{}` for each entry of `args`.
    let message = (
      $diagnostic.args
      | reduce --fold $diagnostic.message {|argument, filled|
        $filled | str replace "{}" $argument
      }
    )

    # nixf counts lines and columns from zero. Editors count from one.
    {
      file: $nix_file
      line: ($diagnostic.range.lCur.line + 1)
      column: ($diagnostic.range.lCur.column + 1)
      rule: $diagnostic.sname
      message: $message
    }
  }
}

def format-finding []: record -> string {
  $"($in.file):($in.line):($in.column): ($in.rule): ($in.message)"
}

def main [source_dir: path] {
  cd $source_dir

  ^statix check .
  ^deadnix --fail .

  let findings = (
    glob **/*.nix --no-dir --exclude [**/.* **/.*/**]
    | path relative-to $env.PWD
    | sort
    | each {|nix_file| collect-diagnostics $nix_file }
    | flatten
  )

  if ($findings | is-empty) {
    return
  }

  $findings
  | each { format-finding }
  | str join (char newline)
  | print --stderr

  exit 1
}
