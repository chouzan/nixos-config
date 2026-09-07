# Administration commands for this system.
#
# Needs these programs on PATH: sudo, lsblk, efibootmgr.

use ../lib/utils.nu print-help

use disk.nu [
  "main disk list"
  "main disk esp"
]

use boot.nu [
  "main boot list"
  "main boot create"
  "main boot delete"
  "main boot order"
  "main boot reorder"
  "main boot next"
]

const script_name = path self | path basename

# Refuse the escalation, not the user. An installer logs in as root and has no
# other account, so `is-admin` here would lock out the install it is for.
if ($env.SUDO_USER? | is-not-empty) {
  error make $"Don't run ($script_name) with sudo. It will escalate its privileges when needed."
}

# Report the disks of this system.
def "main disk" [] {
  print-help $script_name disk
}

# Read or change the firmware boot entries.
def "main boot" [] {
  print-help $script_name boot
}

# Administer this system.
def main [] {
  print-help $script_name
}
