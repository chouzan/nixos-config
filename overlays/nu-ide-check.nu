# Report the parse errors of a Nushell script.
#
# `nu --ide-check` writes one JSON object per line and exits zero even when it
# reports an error, so the diagnostics decide the result rather than the exit
# status.

def locate [source: string, offset: int]: nothing -> record {

  # Splitting the text that precedes the offset gives one piece per line, the
  # last of which is the part of the error's own line that comes before it. So
  # the number of pieces is the line, and the length of the last piece is the
  # column. That last piece is empty when the error sits on the first character
  # of a line, and `lines` discards an empty final piece where `split row`
  # keeps it.
  let preceding_lines = $source | str substring 0..<$offset | split row (char newline)

  {
    line: ($preceding_lines | length)
    column: (($preceding_lines | last | str length --grapheme-clusters) + 1)
  }
}

def main [script: path] {
  let errors = (
    ^nu --no-config-file --ide-check 10 $script
    | lines
    | each {|entry| $entry | from json --strict }
    | where {|entry| ($entry.severity? | default "") == "Error" }
  )

  if ($errors | is-empty) {
    return
  }

  let source = open --raw $script

  $errors
  | each {|diagnostic|
    let at = locate $source $diagnostic.span.start
    $"($script):($at.line):($at.column): ($diagnostic.message)"
  }
  | str join (char newline)
  | print --stderr

  exit 1
}
