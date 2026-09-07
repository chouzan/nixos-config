# Report the firmware boot entries of `efibootmgr` output.
#
# An entry line separates the label from the device path with a tab, and a label
# holds spaces, so the tab is what ends it.
export def "from efibootmgr entries" []: string -> table {
  $in
  | lines
  | parse --regex '^Boot(?<id>[0-9A-Fa-f]{4})(?<active>\*?)\s+(?<label>[^\t]*)\t?(?<device_path>.*)$'
  | update active { $in == "*" }
}

# Report the boot order of `efibootmgr` output.
#
# The order is absent when the firmware holds none.
export def "from efibootmgr order" []: string -> list<string> {
  $in
  | lines
  | parse --regex '^BootOrder:\s*(?<order>.*)$'
  | get --optional order.0
  | default ""
  | split row ","
  | where $it != ""
}
