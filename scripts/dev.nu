# Development commands for this repository.

def current-system []: nothing -> string {
  ^nix eval --impure --raw --expr "builtins.currentSystem"
}

def flake-checks []: nothing -> list<string> {
  ^nix eval $".#checks.((current-system))" --apply "builtins.attrNames" --json
  | from json --strict
}

def secret-scopes []: nothing -> list<string> {
  glob .secrets/secrets.*.yaml
  | path basename
  | parse "secrets.{scope}.yaml"
  | get scope
  | sort
}

def secrets-file [scope: string]: nothing -> string {
  $".secrets/secrets.($scope).yaml"
}

def age-key [scope: string]: nothing -> string {
  $"($env.HOME)/.my/keys/age/($scope).key"
}

# sops reports a missing scope as a configuration error, which does not say
# that the scope is the problem.
def require-scope [scope: string]: nothing -> nothing {
  let scopes = secret-scopes

  if $scope not-in $scopes {
    error make {msg: $"unknown secret scope '($scope)'. Known scopes: ($scopes | str join ', ')."}
  }
}

# Run every flake check, reporting all failures rather than stopping at the
# first one. Pass a name to run a single check.
def "main check" [
  name?: string # Check to run. Omit to run every check.
] {
  if $name == null {
    ^nix flake check --keep-going --print-build-logs
  } else {
    ^nix build $".#checks.((current-system)).($name)" --print-build-logs
  }
}

# List the checks that the flake defines.
def "main check list" [] {
  flake-checks
}

# Format every file that the formatter of the flake covers.
def "main format" [] {
  ^nix fmt
}

# List the secret scopes that this repository holds.
def "main secret list" [] {
  secret-scopes
}

# Open a secret file in an editor, decrypted.
def "main secret edit" [
  scope: string # Secret set to edit. Run `dev secret list` for the choices.
] {
  require-scope $scope

  with-env {SOPS_AGE_KEY_FILE: (age-key $scope)} {
    ^sops edit (secrets-file $scope)
  }
}

# Copy one secret to the clipboard, without writing it to the terminal.
def "main secret copy" [
  scope: string # Secret set to read. Run `dev secret list` for the choices.
  key: string # Key to copy.
] {
  require-scope $scope

  let result = (
    with-env {SOPS_AGE_KEY_FILE: (age-key $scope)} {
      ^sops --decrypt --extract $'["($key)"]' (secrets-file $scope)
      | complete
    }
  )

  # The report carries the message of sops, which separates a missing key from
  # a missing key file. It never carries the secret, which sops writes to
  # standard output.
  if $result.exit_code != 0 {
    error make {msg: $"sops: cannot read '($key)' from ($scope) secrets.\n($result.stderr | str trim)"}
  }

  # sops writes the value with no trailing newline, and `complete` would keep
  # one if that changed. The trim keeps the clipboard free of it either way.
  $result.stdout | str trim --right --char (char newline) | ^wl-copy
  print $"copied '($key)' to the clipboard."
}

def main [] {
  print "Run `dev --help` for the available commands."
}
