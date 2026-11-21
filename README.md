# NixOS Configuration

[![NixOS Unstable](https://img.shields.io/badge/NixOS-unstable-4D6FB7.svg?style=flat&logo=nixos&logoColor=white)](https://nixos.org)
[![NixOS Flakes](https://img.shields.io/badge/NixOS-Flakes-4D6FB7.svg?style=flat&logo=nixos&logoColor=white)](https://wiki.nixos.org/wiki/Flakes)
[![Home Manager](https://img.shields.io/badge/Nix_Community-Home_Manager-4D6FB7.svg?style=flat&logo=nixos&logoColor=white)](https://github.com/nix-community/home-manager)

Personal NixOS configuration with an opinionated abstraction layer over NixOS and Home Manager. **This is a reference implementation** - feel free to learn from it, but it's tailored to my specific needs and workflow.

## What is This?

A modular NixOS configuration that provides high-level feature flags (`modules.*`) instead of raw NixOS options. Set what you want (`modules.programming.elixir.enable = true`) and let implementations handle the details (Elixir packages, extensions in Zed, etc.).

## Quick Example

```nix
# hosts/<hostname>/configuration.nix
{
  imports = [
    ../../profiles/base.nix
    ../../profiles/hardware/amd.nix
    ../../profiles/environment/hyprland.nix
  ];

  modules = {
    packages.cli.enable = true;
    programs.git.enable = true;
    programming.elixir.enable = true;
  };
}
```

## Architecture

```
Custom Options (modules.*)
    ↓
Implementations (opinionated logic)
    ↓
NixOS/Home Manager Options
```

**Key Concepts:**

- **Options** (`modules/<group>/options.nix`) - Define the public API contract
- **Implementations** (`modules/<group>/<feature>/nixos/`, `modules/<group>/<feature>/home/`) - Derive configuration decisions from custom options
- **Profiles** (`profiles/*`) - Preset option combinations with `utils.mkProfileDefault` (easily overridable)
- **Hosts** (`hosts/*`) - Machine-specific configurations

Each implementation file is a [flake-parts](https://flake.parts) module that stores a NixOS or Home Manager module under `flake.modules`. `parts/hosts.nix` gives every host all of them, and the enable flags decide what takes effect.

**Example Flow:**
```nix
# You enable:
modules.programs.zsh.enable = true;

# Implementation derives:
programs.zsh.enable = true;                     # Enable Zsh itself
home.shell.enableZshIntegration = true;         # Every Home Manager program with a Zsh integration picks this up
```

```nix
# You enable:
modules.programming.elixir.enable = true;

# Implementation derives:
home.packages = [ elixir expert ];                  # Toolchain and language server
programs.zed-editor.userSettings.auto_install_extensions.elixir = true;  # Conditional dependency
```

## Project Structure

```
nixos-config/
├── flake.nix           # Inputs and the flake-parts entry point
├── parts/              # Flake outputs, one flake-parts module per concern
│   ├── hosts.nix       # Users, machines, and the modules of every host
│   ├── modules.nix     # Loads modules/
│   ├── packages.nix
│   ├── systems.nix
│   ├── treefmt.nix
│   └── checks/
├── modules/            # Features, grouped by domain
│   ├── <group>/
│   │   ├── options.nix             # Flags of the group (modules.<group>.*)
│   │   └── <feature>/
│   │       ├── nixos/<feature>.nix # NixOS implementation
│   │       ├── home/<feature>.nix  # Home Manager implementation
│   │       └── assets/             # Files that the implementations read
│   └── base/options/   # Options that belong to no group
├── lib/                # Helper functions
├── overlays/           # Package overlays and patches
├── hosts/              # Machine configurations
│   ├── panthera/       # Desktop workstation
│   ├── neofelis/       # Lab machine
│   ├── acinonyx/       # Laptop
│   ├── leopardus/      # Installer ISO
│   ├── otocolobus/     # WSL
│   ├── shared/         # Settings that several hosts use
│   └── template/       # Template for new hosts
├── profiles/           # Convenience presets
│   ├── base.nix
│   ├── hardware/
│   ├── environment/
│   └── role/
├── scripts/            # Installer and helper scripts
└── docs/               # Documentation
```

A group that has one feature, such as `stylix` and `packages`, keeps that feature's `nixos/` and `home/` directories directly in the group directory.

## Available Modules

All available options are defined in the `options.nix` file of each group in `modules/`:

- `modules/system/options.nix` - DNS, XDG, nixosadm, containers
- `modules/hardware/options.nix` - CPU, GPU, battery
- `modules/programs/options.nix` - Individual programs (zsh, git, firefox, zed, etc.)
- `modules/llm/options.nix` - LLM tools, MCP servers, Claude Desktop
- `modules/programming/options.nix` - Language toolchains and development tools
- `modules/packages/options.nix` - Package collections (admin, cli, media, etc.)
- `modules/stylix/options.nix` - Stylix theming
- `modules/desktop/options/` - Hyprland, window rules, and Hyprland monitor settings
- `modules/base/options/` - User, monitors, and personal paths (`~/.my`, scripts, keys)

Each file contains clear option definitions with descriptions.

## Multi-Monitor Setup

```nix
modules.monitors = [
  {
    name = "eDP-1";
    primary = true;
    width = 2880;
    height = 1800;
    refreshRate = 90;
    scale = 1.5;
    hyprland.workspace = "main";
  }
  {
    name = "DP-4";
    width = 3440;
    height = 1440;
    refreshRate = 144;
    hyprland = {
      workspace = "workspace";
      position = "auto-right";
      vrr = 1;
    };
  }
];
```

See `modules/base/options/monitors.nix` and `modules/desktop/options/monitors.nix` for all options.

## Installation

### Bootable Installer (Recommended for Fresh Installs)

Build and use the unified installer ISO:

```bash
nix build .#installer
sudo dd if=result/iso/nixos-installer.iso of=/dev/sdX bs=4M status=progress
```

Boot from USB and run `sudo menu`. The installer supports:
- **Disko method**: Automated, wipes entire disk (single-boot)
- **Manual method**: GParted + script (dual-boot safe)

See [hosts/leopardus/configuration.nix](hosts/leopardus/configuration.nix) for details.

### Manual Setup

**Note:** This is a personal config. If you want to use it as a base, you'll need to adapt it to your needs.

1. **Clone and enter:**
   ```bash
   git clone <repo-url> ~/nixos-config
   cd ~/nixos-config
   ```

2. **Update `parts/hosts.nix` with your information:**
   ```nix
   # User information
   mkUser = username: {
     inherit username;
     name = "<Your Full Name>";    # Your full name
     gitEmail = "<your-email>";    # Your git email
   };

   user = mkUser "<username>";     # Your username

   # Machine configuration
   machines = {
     <hostname> = mkMachine { };
   };
   ```

3. **Create your host:**
   ```bash
   cp -r hosts/template hosts/<hostname>
   nixos-generate-config --show-hardware-config > hosts/<hostname>/hardware-configuration.nix
   ```

4. **Edit configuration:**
   ```bash
   $EDITOR hosts/<hostname>/configuration.nix
   ```

5. **Track the new files.** Flakes only see files that Git tracks:
   ```bash
   git add hosts/<hostname>
   ```

6. **Build and switch:**
   ```bash
   sudo nixos-rebuild switch
   ```

**Note:** It's best to limit the number of cores and jobs to run when doing major upgrades by passing `--option cores <cores> --option max-jobs <jobs>`

## Profiles

Profiles are convenience wrappers that set multiple options at once with `utils.mkProfileDefault`. It sets a priority that a host overrides with a plain assignment:

```nix
# profiles/hardware/amd.nix
{ libs, ... }:

let
  inherit (libs) utils;
in
{
  modules.hardware = {
    cpu.amd.enable = utils.mkProfileDefault true;
    gpu.amd.enable = utils.mkProfileDefault true;
  };
}
```

Import profiles in your host's configuration:
```nix
imports = [
  ../../profiles/base.nix                   # Essential tools
  ../../profiles/hardware/laptop.nix        # Battery optimizations
  ../../profiles/hardware/amd.nix           # AMD CPU + GPU
  ../../profiles/environment/hyprland.nix
  ../../profiles/role/development.nix       # Full dev stack
];
```

Override as needed:
```nix
imports = [ ../../profiles/hardware/amd.nix ];
modules.hardware.gpu.amd.enable = false;        # Disable GPU part
```

## Development

**Format code:**
```bash
nix fmt
```

**Check the flake and the project checks:**
```bash
nix flake check
```

**Add a new feature:**
1. Create `modules/<group>/<feature>/nixos/<feature>.nix` or `modules/<group>/<feature>/home/<feature>.nix`.
2. Define the module in each file as `flake.modules.nixos.<group>-<feature>` or `flake.modules.homeManager.<group>-<feature>`.
3. Declare the flag in `modules/<group>/options.nix`.
4. Gate the configuration with `lib.mkIf cfg.enable { ... }`.
5. Run `git add` on the new files. Flakes ignore files that Git does not track, so an untracked module is silently not loaded.

## Documentation

- [hosts/leopardus/README.md](hosts/leopardus/README.md) - Bootable installer ISO (build, usage, NixOS references)
- [scripts/installer/README.md](scripts/installer/README.md) - Installer scripts documentation
- [docs/STORAGE_DESIGN.md](docs/STORAGE_DESIGN.md) - Storage architecture and configuration reference
- [PARTITIONING.md](docs/PARTITIONING.md) - Installation procedures
- [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) - Common issues
- Architecture details - see `modules/` structure

## License

Personal configuration - use at your own risk.

---

*Made with Nix*
