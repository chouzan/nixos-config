# Import rules for the QML layers of the bar.
#
# A rule names the directory it inspects. A directory that has gone missing
# fails the rule rather than passing it, because an empty search and an absent
# search read the same.

# Every import in a directory, as one row per import statement.
def imports-in [directory: path]: nothing -> table {
  glob $"($directory)/**/*.qml" --no-dir
  | each {|file|
    open --raw $file
    | lines
    | enumerate
    | each {|row|
      $row.item
      | parse --regex '^\s*import\s+"(?<target>[^"]+)"'
      | each {|hit|
        {
          file: ($file | path relative-to $env.PWD)
          line: ($row.index + 1)
          target: $hit.target
        }
      }
    }
    | flatten
  }
  | flatten
}

def offenders [directory: path, keep: closure, message: string]: nothing -> table {
  if not ($directory | path exists) {
    return [
      {file: $directory, line: null, message: "missing directory"}
    ]
  }

  imports-in $directory
  | where $keep
  | each {|import| {file: $import.file, line: $import.line, message: $"($message): ($import.target)"} }
}

def format-finding []: record -> string {
  if $in.line == null {
    $"($in.file): ($in.message)"
  } else {
    $"($in.file):($in.line): ($in.message)"
  }
}

def main [source_dir: path] {
  cd $source_dir

  # The bar composes every domain, so it is the one directory allowed to reach
  # across them.
  let domains = (
    ls components
    | where type == dir
    | get name
    | where {|directory| ($directory | path basename) not-in ["base" "bar"] }
  )

  let findings = [
    (offenders "services" {|import| $import.target | str starts-with "../components" }
      "services must not import interface components")
    (offenders "components/base" {|import| $import.target != "../../config" }
      "components/base can import only config")
    ...($domains | each {|domain|
      (offenders $domain
        {|import| $import.target not-in ["../base" "../../config" "../../services"] }
        $"($domain) can import only base, config, and services")
    })
  ] | flatten

  if ($findings | is-empty) {
    return
  }

  $findings | each { format-finding } | str join (char newline) | print --stderr

  exit 1
}
