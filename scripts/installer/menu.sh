#!/usr/bin/env bash
#
# NixOS Installation Menu
#
# Interactive installer for NixOS with support for:
# - Multiple hosts (panthera, acinonyx, etc.)
# - Disko (automated) or Manual (dual-boot safe) methods
# - Online (clone from git) or Offline (use embedded config) modes
#
# Usage:
#   sudo menu
#
# TODO: Introduce `nixosadm` command for unified admin tasks (like eos from EndeavourOS)
#       - Commit hardware-configuration.nix and stateVersion changes after install
#       - System maintenance, updates, garbage collection
#       - Integration with nh (nix-community/nh) for better UX

set -e

# ─────────────────────────────────────────────────────────────────────────────
# Configuration
# ─────────────────────────────────────────────────────────────────────────────
CONFIG_DIR="/etc/nixos-config"
GIT_REPO="git@github.com:chouzan/nixos-config.git"
GIT_REPO_HTTPS="https://github.com/chouzan/nixos-config.git"
TARGET_DIR="/mnt/etc/nixos"
USERNAME="chouzan"

# Available hosts (add new hosts here)
HOSTS=("panthera" "acinonyx" "neofelis")

# ─────────────────────────────────────────────────────────────────────────────
# Colors and Helpers
# ─────────────────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

log_info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn()    { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error()   { echo -e "${RED}[ERROR]${NC} $1"; }
log_step()    { echo -e "\n${CYAN}==>${NC} ${BOLD}$1${NC}"; }

check_internet() {
    ping -c 1 -W 3 github.com &>/dev/null || ping -c 1 -W 3 1.1.1.1 &>/dev/null
}

# ─────────────────────────────────────────────────────────────────────────────
# Banner
# ─────────────────────────────────────────────────────────────────────────────
show_banner() {
    clear
    echo -e "${CYAN}"
    cat << 'EOF'
╔═══════════════════════════════════════════════════════════════════════╗
║                                                                       ║
║                      NixOS Configuration Installer                    ║
║                                                                       ║
╚═══════════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

# ─────────────────────────────────────────────────────────────────────────────
# Method Selection
# ─────────────────────────────────────────────────────────────────────────────
select_method() {
    echo ""
    echo -e "${BOLD}Select installation method:${NC}"
    echo ""
    echo "  1) Disko (automated)"
    echo "     └─ Wipes entire disk, fully automated"
    echo "     └─ Best for: single-boot, fresh installs"
    echo ""
    echo "  2) Manual (dual-boot safe)"
    echo "     └─ Requires manual partitioning with GParted first"
    echo "     └─ Best for: dual-boot, preserving existing partitions"
    echo ""

    while true; do
        read -p "Enter choice [1/2]: " choice
        case $choice in
            1) METHOD="disko"; break ;;
            2) METHOD="manual"; break ;;
            *) echo "Invalid choice. Enter 1 or 2." ;;
        esac
    done
}

# ─────────────────────────────────────────────────────────────────────────────
# Host Selection
# ─────────────────────────────────────────────────────────────────────────────
select_host() {
    echo ""
    echo -e "${BOLD}Select host configuration:${NC}"
    echo ""

    local i=1
    for host in "${HOSTS[@]}"; do
        local desc=""
        case $host in
            panthera) desc="workstation/desktop" ;;
            acinonyx) desc="laptop" ;;
            neofelis) desc="lab" ;;
            *) desc="" ;;
        esac
        echo "  $i) $host ${desc:+($desc)}"
        ((i++))
    done
    echo ""

    while true; do
        read -p "Enter choice [1-${#HOSTS[@]}]: " choice
        if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#HOSTS[@]}" ]; then
            HOST="${HOSTS[$((choice-1))]}"
            break
        else
            echo "Invalid choice."
        fi
    done
}

# ─────────────────────────────────────────────────────────────────────────────
# Disko Installation
# ─────────────────────────────────────────────────────────────────────────────
install_disko() {
    local disko_config="$CONFIG_DIR/hosts/$HOST/disko.nix"

    if [ ! -f "$disko_config" ]; then
        log_error "No disko.nix found for $HOST at $disko_config"
        log_error "This host may not support disko installation."
        exit 1
    fi

    echo ""
    echo -e "${RED}╔═══════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║  ⚠️  WARNING: This will DESTROY ALL DATA on the target disk!          ║${NC}"
    echo -e "${RED}╚═══════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo "Target disk from disko.nix:"
    grep -o 'device = "[^"]*"' "$disko_config" | head -1 | sed 's/device = /  /'
    echo ""
    echo "Current disks:"
    lsblk -d -o NAME,SIZE,MODEL | sed 's/^/  /'
    echo ""

    read -p "Type 'yes' to continue: " confirm
    if [ "$confirm" != "yes" ]; then
        log_warn "Aborted."
        exit 1
    fi

    log_step "Running disko (partition, format, mount)..."
    nix run github:nix-community/disko -- \
        --mode destroy,format,mount \
        "$disko_config"
    log_success "Disk configured and mounted"

    setup_config
    update_state_version
    run_nixos_install
}

# ─────────────────────────────────────────────────────────────────────────────
# Manual Installation
# ─────────────────────────────────────────────────────────────────────────────
install_manual() {
    local setup_script="$CONFIG_DIR/scripts/installer/manual-partition.sh"

    echo ""
    echo -e "${BOLD}Manual Installation for $HOST${NC}"
    echo ""
    echo "This method requires you to:"
    echo "  1. Create partitions manually with GParted"
    echo "  2. Run the setup script to format and mount"
    echo ""

    if [ -f "$setup_script" ]; then
        echo -e "Setup script found: ${GREEN}$setup_script${NC}"
    else
        log_warn "No setup script found"
        echo "You'll need to manually format and mount partitions to /mnt"
    fi

    echo ""
    echo "Options:"
    echo "  1) Open GParted (create partitions first)"
    echo "  2) Run setup script (after partitions exist)"
    echo "  3) Skip to config setup (partitions already mounted)"
    echo "  4) Cancel"
    echo ""

    while true; do
        read -p "Enter choice [1-4]: " choice
        case $choice in
            1)
                log_info "Opening GParted..."
                gparted
                echo ""
                read -p "Partitions created? Continue to setup script? [y/N]: " cont
                if [[ "$cont" =~ ^[yY] ]]; then
                    run_setup_script "$setup_script"
                    break
                fi
                ;;
            2)
                run_setup_script "$setup_script"
                break
                ;;
            3)
                if mountpoint -q /mnt; then
                    log_success "/mnt is mounted, continuing..."
                    break
                else
                    log_error "/mnt is not mounted. Mount your partitions first."
                fi
                ;;
            4)
                log_warn "Aborted."
                exit 0
                ;;
            *)
                echo "Invalid choice."
                ;;
        esac
    done

    setup_config
    update_state_version
    run_nixos_install
}

run_setup_script() {
    local script="$1"
    if [ -f "$script" ]; then
        log_step "Running setup script..."
        bash "$script"
        log_success "Setup complete"
    else
        log_error "Setup script not found: $script"
        echo "Please manually format and mount partitions to /mnt"
        exit 1
    fi
}

# ─────────────────────────────────────────────────────────────────────────────
# Common Installation Steps
# ─────────────────────────────────────────────────────────────────────────────
setup_config() {
    log_step "Setting up configuration..."
    mkdir -p /mnt/etc

    if [ "$ONLINE" = true ]; then
        log_info "Cloning latest configuration from git..."
        if git clone "$GIT_REPO" "$TARGET_DIR" 2>/dev/null; then
            log_success "Cloned via SSH"
        elif git clone "$GIT_REPO_HTTPS" "$TARGET_DIR" 2>/dev/null; then
            log_success "Cloned via HTTPS"
        else
            log_warn "Clone failed, using embedded config"
            cp -rT "$CONFIG_DIR" "$TARGET_DIR"
            log_success "Copied embedded config"
        fi
    else
        log_info "Copying embedded configuration..."
        cp -rT "$CONFIG_DIR" "$TARGET_DIR"
        log_success "Copied embedded config"
    fi

    # Fix ownership so user can edit and use git without permission issues
    log_info "Setting ownership to $USERNAME..."
    chown -R 1000:users "$TARGET_DIR"
    log_success "Ownership set"
}

update_state_version() {
    log_step "Updating stateVersion..."

    local host_config="$TARGET_DIR/hosts/$HOST/configuration.nix"

    # Generate a temporary config just to get the current NixOS stateVersion
    nixos-generate-config --root /mnt --no-filesystems 2>/dev/null || true

    local generated_config="/mnt/etc/nixos/configuration.nix"

    if [ -f "$generated_config" ] && [ -f "$host_config" ]; then
        local state_version
        state_version=$(grep -oP 'stateVersion = "\K[^"]+' "$generated_config" || echo "")
        if [ -n "$state_version" ]; then
            log_info "Setting stateVersion to $state_version"
            sed -i "s/stateVersion = \"[^\"]*\"/stateVersion = \"$state_version\"/" "$host_config"
        fi
    fi

    # Clean up generated files (we use our own config)
    rm -f /mnt/etc/nixos/configuration.nix /mnt/etc/nixos/hardware-configuration.nix 2>/dev/null || true

    log_success "stateVersion updated"
}

run_nixos_install() {
    log_step "Installing NixOS ($HOST)..."
    cd "$TARGET_DIR"

    # Create /var/lock to prevent dmraid error during installation
    mkdir -p /var/lock

    if [ "$ONLINE" = true ]; then
        nixos-install --root /mnt --flake ".#$HOST"
    else
        nixos-install --root /mnt --flake ".#$HOST" --option substitute false
    fi
    log_success "NixOS installed"

    # Clean up legacy channel directories (we use flakes)
    log_info "Cleaning up legacy channels..."
    rm -rf /mnt/root/.nix-defexpr/channels
    rm -rf /mnt/nix/var/nix/profiles/per-user/root/channels
    log_success "Legacy channels cleaned"

    show_complete
}

show_complete() {
    echo ""
    echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                       Installation Complete!                          ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. Set user password:"
    echo "     nixos-enter --root /mnt -c 'passwd $USERNAME'"
    echo ""
    echo "  2. Reboot:"
    echo "     reboot"
    echo ""

    if [ "$ONLINE" = false ]; then
        echo "  3. After reboot (when online), set up git:"
        echo "     cd /etc/nixos"
        echo "     git init && git remote add origin $GIT_REPO"
        echo "     git fetch && git reset --hard origin/main"
        echo ""
    fi
}

# ─────────────────────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────────────────────
main() {
    show_banner

    # Check connectivity
    echo ""
    if check_internet; then
        ONLINE=true
        log_success "Internet connected — will clone latest config & fetch packages"
    else
        ONLINE=false
        log_warn "No internet — will use embedded config & cached packages"
    fi

    select_method
    select_host

    echo ""
    log_info "Method: $METHOD"
    log_info "Host: $HOST"
    log_info "Online: $ONLINE"
    echo ""

    case $METHOD in
        disko)  install_disko ;;
        manual) install_manual ;;
    esac
}

main "$@"
