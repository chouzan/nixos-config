# Print the help for one of the calling script's commands.
#
# Nushell names a script's commands after its file, so `--help` reports that
# name while `help main` reports `main`. Asking by the file name matches both.
#
# The caller passes the name, because `path self` here would report this file.
export def print-help [script_name: string, ...words: string]: nothing -> nothing {
  help ...[$script_name ...$words] | print
}

# Run a program as root.
#
# The program is passed by path, because sudo gives the command a different
# PATH.
#
# Redirect the output rather than `ignore` it, which would swallow the exit
# status too. stderr stays open for the password prompt.
#
# `--wrapped` keeps the program's flags out of this command's own parsing.
export def --wrapped run-as-root [program: string, ...arguments: string]: nothing -> nothing {
  let resolved = which $program | get path.0

  ^sudo $resolved ...$arguments o> /dev/null
}
