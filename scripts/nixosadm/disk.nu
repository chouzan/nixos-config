# Report every partition, carrying the path of the disk that holds it.
#
# The nested form is what carries the disk, since `--list` flattens it and
# names the disk by kernel name alone.
export def partitions []: nothing -> table {
  ^lsblk --json --output NAME,PARTN,PARTTYPE,PARTLABEL,FSTYPE,LABEL,MOUNTPOINTS,PATH
  | from json --strict
  | get blockdevices
  | each {|disk|
    $disk.children?
    | default []
    | insert disk_path $disk.path
  }
  | flatten
  | rename --column {
    partn: number,
    parttype: type,
    partlabel: label,
    fstype: fs_type,
    label: fs_label,
    mountpoints: mount_points
  }
}

# Report the partition mounted at a mount point.
export def partition-at [mount_point: string]: nothing -> record {
  let match = partitions | where $mount_point in $it.mount_points

  if ($match | is-empty) {
    error make {
      msg: $"No partition mounted at '($mount_point)'.",
      help: "Run `nixosadm disk list` to see the partitions."
    }
  }

  $match | first
}

# Report the partition at a device path, following any link to it.
export def partition-by-path [path: string]: nothing -> record {
  let expanded = $path | path expand
  let match = partitions | where path == $expanded

  if ($match | is-empty) {
    error make {
      msg: $"No partition at '($path)'.",
      help: "Run `nixosadm disk list` to see the partitions."
    }
  }

  $match | first
}

# Report the system partitions.
export def "main disk list" [] {
  partitions
}

# The type a GPT partition table gives an EFI system partition.
export const esp_partition_type = "c12a7328-f81f-11d2-ba4b-00a0c93ec93b"

# Report the EFI system partitions.
export def "main disk esp" [] {
  partitions | where ($it.type | default "" | str lowercase) == $esp_partition_type
}
