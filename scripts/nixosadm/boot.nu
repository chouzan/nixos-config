use ../lib/from-parsers.nu [
  "from efibootmgr entries"
  "from efibootmgr order"
]

use ../lib/utils.nu run-as-root
use disk.nu

def entries []: nothing -> table {
  ^efibootmgr | from efibootmgr entries
}

# A number names an entry only while that entry exists. Creating one takes the
# lowest free number, so a deleted number later names something else.
def find-entry [id: string, known: table]: nothing -> record {
  if not ($id =~ '^[0-9A-Fa-f]{4}$') {
    error make {
      msg: $"'($id)' is not a boot entry number.",
      help: "Run `nixosadm boot list` to see the boot entries."
    }
  }

  let matches = $known | where id == ($id | str uppercase)

  if ($matches | is-empty) {
    error make {
      msg: $"No boot entry numbered '($id)'.",
      help: "Run `nixosadm boot list` to see the boot entries."
    }
  }

  $matches | first
}

# The partition mounted here holds the loader of the running system.
const esp_mount_point = "/boot/efi"

# efibootmgr takes a disk and a partition number, not a partition device.
def esp-disk [device: string]: nothing -> record<disk_path: string, partition_number: int> {
  let partition = if ($device | is-empty) {
    disk partition-at $esp_mount_point
  } else {
    disk partition-by-path $device
  }

  if ($partition.type | default "" | str lowercase) != $disk.esp_partition_type {
    error make {
      msg: $"'($partition.path)' is not an EFI system partition.",
      help: "Run `nixosadm disk esp` to see the EFI system partitions."
    }
  }

  {disk_path: $partition.disk_path, partition_number: $partition.number}
}

# List the firmware boot entries.
export def "main boot list" [] {
  entries
}

# Create a firmware boot entry for the loader this system installs.
#
# NixOS writes the loader but never the entry, because installing at the
# fallback path forbids writing firmware variables. The entry outlives every
# rebuild, and is lost if firmware forgets its variables.
export def "main boot create" [
  --label: string = "NixOS" # Name to show in the firmware boot menu.
  --host: string # Name appended to the label. Defaults to this host. Pass an empty name to append nothing.
  --loader: string = '\EFI\NixOS\grubx64.efi' # Loader path within the partition.
  --partition: string = "" # EFI system partition holding the loader. Defaults to the one mounted for this system.
] {
  if ($label | is-empty) {
    error make {
      msg: "No boot entry name given.",
      help: "Pass --label, or leave it at its default."
    }
  }

  # Installing another host names that host, not this one, so the name is a
  # parameter. An empty name is not an absent one, and asks for a label with no
  # host.
  let host = if $host == null { sys host | get hostname } else { $host }

  let label = if ($host | is-empty) {
    $label
  } else {
    $"($label) \(($host)\)"
  }

  let existing = entries | where label == $label

  if ($existing | is-not-empty) {
    error make {
      msg: $"A boot entry named '($label)' exists as Boot($existing.id.0).",
      help: $"Delete it first with `nixosadm boot delete ($existing.id.0)`."
    }
  }

  let esp = esp-disk $partition

  print $"creating '($label)' for ($esp.disk_path) partition ($esp.partition_number): ($loader)"

  run-as-root efibootmgr --create --disk $esp.disk_path --part $esp.partition_number --label $label --loader $loader

  print $"entry created. Run `nixosadm boot list` for its number, then move it with `nixosadm boot reorder`, or in the firmware setup where a written order does not survive a reboot."
}

# Delete a firmware boot entry.
export def "main boot delete" [id: string] {
  let entry = find-entry $id (entries)

  run-as-root efibootmgr --bootnum $entry.id --delete-bootnum

  print $"deleted Boot($entry.id) '($entry.label)'."
}

# Report the boot order.
export def "main boot order" [] {
  ^efibootmgr | from efibootmgr order
}

# Move the numbered entries to the front of the boot order.
#
# The entries left out keep their order behind them.
#
# Firmware may keep its own order and rebuild this one at boot, discarding what
# is written here. Where that happens, set the order in the firmware setup.
export def "main boot reorder" [...ids: string] {
  if ($ids | is-empty) {
    error make {
      msg: "No boot entry number given.",
      help: "Run `nixosadm boot list` to see the boot entries."
    }
  }

  # One read answers both what exists and what the order is.
  let output = ^efibootmgr
  let known = $output | from efibootmgr entries

  # Check every number before writing. `each` would hide which one failed.
  for id in $ids { find-entry $id $known }

  # Firmware prints numbers in upper case; match it so a number already in the
  # order is recognised.
  let ids = $ids | each { $in | str uppercase } | uniq

  let order = $ids ++ ($output | from efibootmgr order | where $it not-in $ids)

  run-as-root efibootmgr --bootorder ($order | str join ",")

  print $"boot order: ($order | str join ", ")"
}

# Boot the numbered entry once, leaving the boot order alone.
export def "main boot next" [id: string] {
  let entry = find-entry $id (entries)

  run-as-root efibootmgr --bootnext $entry.id

  print $"next boot: Boot($entry.id) '($entry.label)'."
}
