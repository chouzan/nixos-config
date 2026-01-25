# NixOS Configuration

[![NixOS Unstable](https://img.shields.io/badge/NixOS-unstable-4D6FB7.svg?style=flat&logo=nixos&logoColor=white)](https://nixos.org)
[![NixOS Flakes](https://img.shields.io/badge/NixOS-Flakes-4D6FB7.svg?style=flat&logo=nixos&logoColor=white)](https://wiki.nixos.org/wiki/Flakes)
[![Home Manager](https://img.shields.io/badge/Nix_Community-Home_Manager-4D6FB7.svg?style=flat&logo=nixos&logoColor=white)](https://github.com/nix-community/home-manager)

Personal NixOS configuration with an opinionated abstraction layer over NixOS and Home Manager. **This is a reference implementation** - feel free to learn from it, but it's tailored to my specific needs and workflow.

## What is This?

A modular NixOS configuration that provides high-level feature flags (`modules.*`) instead of raw NixOS options. Set what you want (`modules.bundles.dev.elixir.enable = true`) and let implementations handle the details (Elixir packages, LSP integration in Zed, shell completions, etc.).

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
    packages.extras.enable = true;
    programs.git.enable = true;
    bundles.dev.elixir.enable = true;
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

- **Options** (`modules/options/*`) - Define the public API contract
- **Implementations** (`modules/nixos/*`, `modules/home/*`) - Derive configuration decisions from custom options
- **Profiles** (`profiles/*`) - Preset option combinations with `lib.mkDefault` (easily overridable)
- **Hosts** (`hosts/*`) - Machine-specific configurations

**Example Flow:**
```nix
# You enable:
modules.programs.zsh.enable = true;

# Implementation derives:
programs.zsh.enable = true;                     # Enable Zsh itself
programs.bat.enableZshIntegration = true;       # Auto-integration
programs.fzf.enableZshIntegration = true;       # Cross-cutting concern
services.gpg-agent.enableZshIntegration = true;
```

```nix
# You enable:
modules.bundles.dev.elixir.enable = true;

# Implementation derives:
environment.systemPackages = [ elixir elixir-ls ];
programs.zed.extensions = [ "elixir" ];             # Conditional dependency
# ... and more
```

## Project Structure

```
nixos-config/
├── flake.nix           # Entry point
├── lib/                # Helper functions
├── hosts/              # Machine configurations
│   ├── panthera/       # Desktop workstation
│   ├── neofelis/       # Lab machine
│   ├── acinonyx/       # Laptop
│   ├── leopardus/      # Installer ISO
│   └── default/        # Template for new hosts
├── profiles/           # Convenience presets
│   ├── base.nix
│   ├── hardware/
│   ├── environment/
│   └── role/
├── modules/
│   ├── options/        # API contract (modules.*)
│   ├── nixos/          # NixOS implementations
│   ├── home/           # Home Manager implementations
│   └── nix/            # Nix daemon & community settings
└── docs/               # Documentation
```

## Available Modules

All available options are defined in `modules/options/`. The files are organized by category for easy discovery:

- `modules/options/hardware.nix` - CPU, GPU, battery, etc.
- `modules/options/system.nix` - System configuration (XDG, fonts, secrets)
- `modules/options/stylix.nix` - Stylix theming configuration
- `modules/options/desktop/` - Desktop environments
- `modules/options/packages.nix` - Package collections (admin, cli, media, etc.)
- `modules/options/programs.nix` - Individual programs (zsh, git, firefox, zed, etc.)
- `modules/options/bundles.nix` - Feature bundles (containers, dev tools, AI, etc.)
- `modules/options/monitors.nix` - Monitor configuration
- `modules/options/my.nix` - Personal paths configuration (~/.my, scripts, keys)

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

See `modules/options/monitors.nix` and `modules/options/desktop/hyprland/monitors.nix` for all options.

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

2. **Update `flake.nix` with your information:**
   ```nix
   # User information
   user = rec {
     username = "<username>";      # Your username
     name = "<Your Full Name>";    # Your full name
     gitEmail = "<your-email>";    # Your git email
     # ... homeDir is derived from username
   };
   
   # Machine configuration
   machines = {
     <hostname> = mkMachine {
       hostname = "<hostname>";
     };
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

5. **Build and switch:**
   ```bash
   sudo nixos-rebuild switch
   ```

**Note:** It's best to limit the number of cores and jobs to run when doing major upgrades by passing `--option cores <cores> --option max-jobs <jobs>`

## Profiles

Profiles are convenience wrappers that set multiple options at once with `lib.mkDefault`:

```nix
# profiles/hardware/amd.nix
modules.hardware = {
  cpu.amd.enable = lib.mkDefault true;
  gpu.amd.enable = lib.mkDefault true;
};
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

**Debug configurations:**
```bash
nix eval .#debug.machines --json | jq
```

**Add new module:**
1. Define option in `modules/options/<category>.nix`
2. Implement in `modules/nixos/<category>/` or `modules/home/<category>/`
3. Use `lib.mkIf cfg.enable { ... }` pattern

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
