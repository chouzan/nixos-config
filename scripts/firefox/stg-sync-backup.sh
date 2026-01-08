#!/usr/bin/env bash
#
# stg-sync-backup.sh - Sync Simple Tab Groups backup with NixOS configuration
#
# This script takes an STG backup and syncs it with your NixOS configuration:
# - Updates container IDs to match containers.nix
# - Updates group IDs to match simple-tab-groups-settings.json
# - Syncs group settings (colors, behaviors, container mappings)
# - Removes extension settings (managed by home-manager)
# - Keeps state data (tabs, pinnedTabs, containers)
#
# Usage:
#   stg-sync-backup.sh <input-backup.json> [output.json]
#
# Example:
#   stg-sync-backup.sh ~/Downloads/stg-backup-2026-01-07.json

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Default paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NIXOS_DIR="${SCRIPT_DIR}/../.."
SETTINGS_FILE="${NIXOS_DIR}/modules/home/programs/firefox/extensions/simple-tab-groups-settings.json"

show_help() {
    cat << EOF
$(basename "$0") - Sync Simple Tab Groups backup with NixOS configuration

USAGE:
    $(basename "$0") <input-backup.json> [output.json]

DESCRIPTION:
    Syncs an STG backup with your NixOS configuration:

    SYNCED FROM CONFIG:
    - Group IDs (remapped to 1-14)
    - Group settings (colors, containers, behaviors)
    - Container IDs (remapped to 1-10)
    - Container colors/icons (from containers.nix)
    - Hotkeys (group ID references)
    - defaultGroupProps, lastCreatedGroupPosition

    KEPT FROM BACKUP (state):
    - Tabs (URLs, titles, container references)
    - Pinned tabs
    - Container cache

    REMOVED (managed by home-manager):
    - Extension settings (theme, autoBackup, UI preferences)

OPTIONS:
    -h, --help      Show this help message
    -s, --settings  Path to settings JSON (default: auto-detect)

EXAMPLES:
    $(basename "$0") ~/Downloads/stg-backup.json
    $(basename "$0") backup.json synced-backup.json

EOF
}

error() {
    echo -e "${RED}Error:${NC} $1" >&2
    exit 1
}

info() {
    echo -e "${BLUE}==>${NC} $1"
}

success() {
    echo -e "${GREEN}✓${NC} $1"
}

warn() {
    echo -e "${YELLOW}Warning:${NC} $1"
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -s|--settings)
            SETTINGS_FILE="$2"
            shift 2
            ;;
        *)
            break
            ;;
    esac
done

if [[ $# -eq 0 ]]; then
    show_help
    exit 0
fi

INPUT_FILE="$1"
OUTPUT_FILE="${2:-}"

# Validate
[[ ! -f "$INPUT_FILE" ]] && error "Input file not found: $INPUT_FILE"
[[ ! -f "$SETTINGS_FILE" ]] && error "Settings file not found: $SETTINGS_FILE"
command -v jq >/dev/null 2>&1 || error "jq is required but not installed"

# Generate output filename
if [[ -z "$OUTPUT_FILE" ]]; then
    INPUT_DIR=$(dirname "$INPUT_FILE")
    if [[ "$INPUT_FILE" =~ ([0-9]{4}-[0-9]{2}-[0-9]{2}) ]]; then
        DATE="${BASH_REMATCH[1]}"
        OUTPUT_FILE="$INPUT_DIR/stg-backup-synced-$DATE.json"
    else
        OUTPUT_FILE="$INPUT_DIR/stg-backup-synced-$(date +%Y-%m-%d).json"
    fi
fi

info "Syncing STG backup with NixOS configuration..."
echo "  Input:    $INPUT_FILE"
echo "  Settings: $SETTINGS_FILE"
echo "  Output:   $OUTPUT_FILE"
echo ""

# Validate JSON
if ! jq empty "$INPUT_FILE" 2>/dev/null; then
    error "Invalid JSON in input file"
fi

if ! jq -e '.version and .groups' "$INPUT_FILE" >/dev/null 2>&1; then
    error "Input file doesn't appear to be a valid STG backup"
fi

# Get stats
GROUPS_COUNT=$(jq '.groups | length' "$INPUT_FILE")
TABS_COUNT=$(jq '[.groups[].tabs | length] | add' "$INPUT_FILE")
PINNED_COUNT=$(jq '.pinnedTabs | length // 0' "$INPUT_FILE")

info "Found $GROUPS_COUNT groups with $TABS_COUNT tabs ($PINNED_COUNT pinned)"

# Validate container names match
info "Validating container names..."

# Get container names from backup
BACKUP_CONTAINERS=$(jq -r '.containers // {} | to_entries[] | .value.name' "$INPUT_FILE" | sort -u)

# Container names from container_info (in script)
CONFIG_CONTAINERS="Personal
Zestead
Product Research
Profession
Work
Finance
Transaction
Social
Anonymous
Mum's"

# Check for unmatched containers and collect their paths
UNMATCHED=""
UNMATCHED_DETAILS=""
while IFS= read -r backup_container; do
    if [[ -n "$backup_container" ]]; then
        if ! echo "$CONFIG_CONTAINERS" | grep -Fxq "$backup_container"; then
            # Find the container ID for this name
            CONTAINER_ID=$(jq -r ".containers // {} | to_entries[] | select(.value.name == \"$backup_container\") | .key" "$INPUT_FILE")
            UNMATCHED="${UNMATCHED}  - \"$backup_container\" (ID: $CONTAINER_ID)\n"
            UNMATCHED_DETAILS="${UNMATCHED_DETAILS}    .containers[\"$CONTAINER_ID\"].name\n"
        fi
    fi
done <<< "$BACKUP_CONTAINERS"

if [[ -n "$UNMATCHED" ]]; then
    echo ""
    error "Container name mismatch detected!

Found containers in backup that don't match your configuration:
${UNMATCHED}
Backup file location(s):
${UNMATCHED_DETAILS}
Your configured containers:
$(echo "$CONFIG_CONTAINERS" | sed 's/^/  - /')

OPTIONS TO FIX:

Option 1: Update the backup file
  Edit: $INPUT_FILE
  Change the container names to match your configuration.

  Example with jq:
    jq '.containers[\"$CONTAINER_ID\"].name = \"NewName\"' backup.json > fixed.json

Option 2: Update the script's container_info
  Edit: $0
  Add missing containers to the container_info function (around line 153).
  Make sure the names match your containers.nix configuration."
fi

success "All container names validated"

# Validate group titles match
info "Validating group titles..."

# Get group titles from backup
BACKUP_GROUPS=$(jq -r '.groups[] | .title' "$INPUT_FILE" | sort -u)

# Get group titles from config
CONFIG_GROUPS=$(jq -r '.groups[] | .title' "$SETTINGS_FILE" | sort -u)

# Check for unmatched groups
UNMATCHED_GROUPS=""
UNMATCHED_GROUP_DETAILS=""
while IFS= read -r backup_group; do
    if [[ -n "$backup_group" ]]; then
        if ! echo "$CONFIG_GROUPS" | grep -Fxq "$backup_group"; then
            # Find the group ID for this title
            GROUP_ID=$(jq -r ".groups[] | select(.title == \"$backup_group\") | .id" "$INPUT_FILE")
            UNMATCHED_GROUPS="${UNMATCHED_GROUPS}  - \"$backup_group\" (ID: $GROUP_ID)\n"
            UNMATCHED_GROUP_DETAILS="${UNMATCHED_GROUP_DETAILS}    .groups[] | select(.id == $GROUP_ID) | .title\n"
        fi
    fi
done <<< "$BACKUP_GROUPS"

if [[ -n "$UNMATCHED_GROUPS" ]]; then
    echo ""
    error "Group title mismatch detected!

Found groups in backup that don't match your configuration:
${UNMATCHED_GROUPS}
Backup file location(s):
${UNMATCHED_GROUP_DETAILS}
Your configured groups:
$(echo "$CONFIG_GROUPS" | sed 's/^/  - /')

OPTIONS TO FIX:

Option 1: Update the backup file
  Edit: $INPUT_FILE
  Change the group titles to match your configuration.

  Example with jq:
    jq '(.groups[] | select(.id == GROUP_ID) | .title) = \"NewTitle\"' backup.json > fixed.json

Option 2: Update the settings file
  Edit: $SETTINGS_FILE
  Add missing groups to match your backup, or rename existing groups."
fi

success "All group titles validated"

# Sync backup with config
info "Syncing..."

jq '
  # Container info from containers.nix (target configuration)
  def container_info:
    {
      "firefox-container-1": {name: "Personal", color: "blue", colorCode: "#37adff", icon: "fingerprint"},
      "firefox-container-2": {name: "Zestead", color: "turquoise", colorCode: "#00c79a", icon: "briefcase"},
      "firefox-container-3": {name: "Product Research", color: "purple", colorCode: "#af51f5", icon: "briefcase"},
      "firefox-container-4": {name: "Profession", color: "blue", colorCode: "#37adff", icon: "briefcase"},
      "firefox-container-5": {name: "Work", color: "orange", colorCode: "#ff9f00", icon: "briefcase"},
      "firefox-container-6": {name: "Finance", color: "green", colorCode: "#51cd00", icon: "dollar"},
      "firefox-container-7": {name: "Transaction", color: "pink", colorCode: "#ff4bda", icon: "cart"},
      "firefox-container-8": {name: "Social", color: "turquoise", colorCode: "#00c79a", icon: "fingerprint"},
      "firefox-container-9": {name: "Anonymous", color: "red", colorCode: "#ff613d", icon: "fingerprint"},
      "firefox-container-10": {name: "Mum'\''s", color: "purple", colorCode: "#af51f5", icon: "fingerprint"}
    };

  # Build dynamic container ID mapping based on name matching
  def build_container_mapping:
    container_info as $info |

    # Build name -> newID mapping from container_info
    ($info | to_entries | map({key: .value.name, value: .key}) | from_entries) as $nameToNewId |

    # Build oldID -> name mapping from backup containers
    (.containers // {} | to_entries | map({key: .key, value: .value.name}) | from_entries) as $oldIdToName |

    # Build oldID -> newID mapping by matching names
    ($oldIdToName | to_entries | map(
      .key as $oldId |
      .value as $name |
      if $nameToNewId[$name] then
        {key: $oldId, value: $nameToNewId[$name]}
      else
        {key: $oldId, value: $oldId}  # Keep same if no match
      end
    ) | from_entries);

  # Apply container ID mapping using the dynamic map
  def fix_container($mapping):
    if . == null then .
    else $mapping[.] // .
    end;

  # Build dynamic group ID mapping based on title matching
  def build_group_mapping:
    $settings[0] as $config |

    # Build title -> newID mapping from config
    ($config.groups | map({key: .title, value: .id}) | from_entries) as $titleToNewId |

    # Build oldID -> title mapping from backup groups
    (.groups | map({key: (.id | tostring), value: .title}) | from_entries) as $oldIdToTitle |

    # Build oldID -> newID mapping by matching titles
    ($oldIdToTitle | to_entries | map(
      .key as $oldId |
      .value as $title |
      if $titleToNewId[$title] then
        {key: $oldId, value: $titleToNewId[$title]}
      else
        {key: $oldId, value: ($oldId | tonumber)}
      end
    ) | from_entries);

  # Apply group ID mapping using the dynamic map
  def fix_group_id($mapping):
    if . == null then .
    else $mapping[(. | tostring)] // .
    end;

  . as $backup |
  $settings[0] as $config |

  # Build the container mapping dynamically based on names
  ($backup | build_container_mapping) as $containerMapping |

  # Build the group mapping dynamically based on titles
  ($backup | build_group_mapping) as $groupMapping |

  # Step 1: Fix IDs and containers in groups, merge settings from config
  ($backup.groups | map(
    .id |= fix_group_id($groupMapping) |
    .tabs |= map(.cookieStoreId |= fix_container($containerMapping)) |
    . as $backupGroup |
    ($config.groups[] | select(.id == $backupGroup.id)) as $configGroup |
    if $configGroup then
      $configGroup + { tabs: $backupGroup.tabs, bookmarkId: $backupGroup.bookmarkId }
    else
      . |
      .newTabContainer |= fix_container($containerMapping) |
      .catchTabContainers |= map(fix_container($containerMapping)) |
      .excludeContainersForReOpen |= map(fix_container($containerMapping))
    end
  )) as $syncedGroups |

  # Step 2: Fix pinned tabs
  ($backup.pinnedTabs | map(.cookieStoreId |= fix_container($containerMapping))) as $syncedPinnedTabs |

  # Step 3: Build containers from container_info
  (container_info as $info |
    $info | to_entries | map({
      key: .key,
      value: {
        name: .value.name,
        icon: .value.icon,
        iconUrl: "resource://usercontext-content/\(.value.icon).svg",
        color: .value.color,
        colorCode: .value.colorCode,
        cookieStoreId: .key
      }
    }) | from_entries
  ) as $syncedContainers |

  # Step 4: Build final output (state + synced config, no extension settings)
  {
    version: $backup.version,
    groups: $syncedGroups,
    pinnedTabs: $syncedPinnedTabs,
    containers: $syncedContainers,
    hotkeys: ($config.hotkeys // [] | map(.groupId |= fix_group_id($groupMapping))),
    defaultGroupProps: $config.defaultGroupProps,
    lastCreatedGroupPosition: ([$config.groups[].id] | max)
  }
' \
  --slurpfile settings "$SETTINGS_FILE" \
  "$INPUT_FILE" > "$OUTPUT_FILE"

# Validate output
if ! jq empty "$OUTPUT_FILE" 2>/dev/null; then
    error "Generated invalid JSON"
fi

# Final stats
OUTPUT_GROUPS=$(jq '.groups | length' "$OUTPUT_FILE")
OUTPUT_TABS=$(jq '[.groups[].tabs | length] | add' "$OUTPUT_FILE")
OUTPUT_PINNED=$(jq '.pinnedTabs | length' "$OUTPUT_FILE")
OUTPUT_CONTAINERS=$(jq '.containers | length' "$OUTPUT_FILE")
INPUT_SIZE=$(du -h "$INPUT_FILE" | cut -f1)
OUTPUT_SIZE=$(du -h "$OUTPUT_FILE" | cut -f1)

echo ""
success "Backup synced successfully!"
echo ""
echo "Summary:"
echo "  Input size:   $INPUT_SIZE"
echo "  Output size:  $OUTPUT_SIZE"
echo "  Groups:       $OUTPUT_GROUPS"
echo "  Tabs:         $OUTPUT_TABS"
echo "  Pinned tabs:  $OUTPUT_PINNED"
echo "  Containers:   $OUTPUT_CONTAINERS"
echo ""
echo "Synced:"
echo "  ✓ Group IDs (1-14)"
echo "  ✓ Group settings (colors, containers, behaviors)"
echo "  ✓ Container IDs and colors"
echo "  ✓ Tab container references"
echo "  ✓ Hotkeys and defaultGroupProps"
echo ""
echo "Removed (managed by home-manager):"
echo "  - Extension settings (theme, autoBackup, UI preferences)"
echo ""
info "To restore: Firefox → STG → Settings → Import Data → $OUTPUT_FILE"
