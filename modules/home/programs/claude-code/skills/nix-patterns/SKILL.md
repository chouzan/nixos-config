---
name: nix-patterns
description: NixOS module patterns for this flake. Apply when writing or reviewing NixOS/home-manager modules, creating options, debugging module conflicts, or working with the type system.
---

# NixOS Module Patterns

## Project Conventions

### Priority Hierarchy

This flake uses custom override priorities between NixOS defaults:

```nix
# Priority (lower = higher priority):
# - mkOptionDefault (1500) - NixOS option defaults
# - mkModuleDefault (1450) - Module-level defaults (utils.mkModuleDefault)
# - mkProfileDefault (1350) - Profile-level defaults (utils.mkProfileDefault)
# - mkDefault (1000) - User defaults
# - mkForce (50) - Force override

# Usage in modules that need utils:
{ libs, ... }:
let
  inherit (libs) utils;
in
{
  config.setting = utils.mkModuleDefault "value";  # Overridable by profiles
  config.other = utils.mkProfileDefault "value";   # Overridable by user config
}
```

### Module Structure

**Home-manager modules:**
```nix
{ osConfig, config, lib, pkgs, machine, ... }:

let
  inherit (osConfig) modules;
  cfg = modules.feature;
in
{
  config = lib.mkIf cfg.enable {
    # Implementation
  };
}
```

**NixOS modules:**
```nix
{ config, lib, ... }:

let
  inherit (config) modules;
  cfg = modules.feature;
in
{
  config = lib.mkIf cfg.enable {
    # Implementation
  };
}
```

**When using utils (add `libs` to args):**
```nix
{ config, lib, libs, ... }:

let
  inherit (config) modules;
  inherit (libs) utils;
in
{ }
```

## Core Patterns

### Enable Option Pattern

```nix
options.modules.feature.enable = mkEnableOption "feature";

config = mkIf cfg.enable {
  # Feature implementation
};
```

### Option Extension Pattern

```nix
# ✅ Extend existing options
options.modules.newOption = mkOption { ... };

# ❌ Don't redefine entire block (causes conflicts)
options.modules = { ... };
```

### Assertion Pattern

```nix
config.assertions = [
  {
    assertion = condition;
    message = "Clear error message with solution";
  }
];
```

Example from monitors.nix:
```nix
config.assertions = lib.optionals ((lib.length modules.monitors) != 0) [
  {
    assertion = (lib.length (lib.filter (m: m.primary) modules.monitors)) == 1;
    message = ''
      Exactly one monitor must be set to primary when monitors are configured.
      Assign `primary = true` to exactly one monitor.
    '';
  }
];
```

## Type System

### LSP-Friendly Options

```nix
options.field = mkOption {
  type = types.str;
  description = "Detailed description for nixd";
  example = "example value";
  default = "default";
};
```

### Submodule for Structured Options

```nix
options.monitors = mkOption {
  type = types.listOf (types.submodule {
    options = {
      name = mkOption { type = types.str; };
      width = mkOption { type = types.ints.positive; };
    };
  });
};
```

## Testing

```bash
# Evaluate specific option
nix eval .#nixosConfigurations.panthera.options.modules.option

# Check all configurations
nix flake check

# Dry build
nixos-rebuild dry-build --flake .#panthera
```

## Common Pitfalls

### Option Conflicts

```nix
# ❌ Creates conflicts
options.modules = { optionA = ...; };
options.modules = { optionB = ...; };

# ✅ Extend instead
options.modules.optionA = ...;
options.modules.optionB = ...;
```

### Type Safety

- Use specific types over generic ones
- Add validation through assertions
- Use enum types for limited choices
- Provide clear error messages
