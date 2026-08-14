# Lint the QML sources of the bar.
#
# The sources hold Nix template placeholders, which are not valid QML, so the
# check works on a writable copy where each placeholder carries a value of the
# right type. The copy also needs the qmldir files that the Nix module
# generates, because a singleton is only resolvable through one.

const lint_tree = "tree"

def prepare-source-tree [source_dir: path]: nothing -> nothing {
  cp --recursive $source_dir $lint_tree
  ^chmod --recursive +w $lint_tree
}

def replace-template-values []: nothing -> nothing {
  let config = [$lint_tree config Config.qml] | path join

  open --raw $config
  | str replace --all "@fontFamily@" "sans-serif"
  | str replace --all "@fontFamilyMono@" "monospace"
  | str replace --all "@fontSizeBase@" "10"
  | str replace --all "@whereAmI@" "/bin/true"
  | save --force $config

  let theme = [$lint_tree config Theme.qml] | path join

  open --raw $theme
  | str replace --all --regex '@base[0-9A-F]{2}@' "#000000"
  | save --force $theme
}

# A qmldir lists every type in its directory, and only a directory holding a
# singleton needs one.
def write-qmldirs []: nothing -> nothing {
  glob $"($lint_tree)/**/*.qml" --no-dir
  | group-by {|file| $file | path dirname }
  | items {|directory, files|
    let types = $files | each {|file| {
      name: ($file | path basename | str replace ".qml" "")
      singleton: (open --raw $file | str contains "pragma Singleton")
    } }

    if ($types | any {|type| $type.singleton }) {
      $types
      | each {|type|
        if $type.singleton {
          $"singleton ($type.name) 1.0 ($type.name).qml"
        } else {
          $"($type.name) 1.0 ($type.name).qml"
        }
      }
      | str join (char newline)
      | save --force ([$directory qmldir] | path join)
    }
  }
  | ignore
}

def main [source_dir: path, quickshell_qml_dir: path, qt_qml_dir: path] {
  prepare-source-tree $source_dir
  replace-template-values
  write-qmldirs

  let qml_files = glob $"($lint_tree)/**/*.qml" --no-dir

  ^qmllint -I $quickshell_qml_dir -I $qt_qml_dir -I $lint_tree ...$qml_files
}
