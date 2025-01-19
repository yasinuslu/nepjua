# Nix Configuration System

A modular, auto-discovering Nix configuration system built with flake-parts.

## Implementation Plan

### Development Approach

We follow a REPL-driven development process:

- Every feature is first tested in the REPL
- Each step must be verifiable in the REPL
- No implementation proceeds without REPL validation
- REPL sessions serve as living documentation
- Complex features are broken down into REPL-testable chunks

Example REPL workflow:

```nix
# 1. Test file discovery
nix repl
> :lf .#
> :p flakeModules.nixos.features.desktop
```

### Phase 1: Basic Structure

- [ ] Set up basic flake with flake-parts
- [ ] Create minimal directory structure
- [ ] Implement basic file discovery (find all default.nix files)
- [ ] Create a simple test module to verify discovery

### Phase 2: Module System

- [ ] Implement basic module wrapping (just the enable flag)
- [ ] Create namespace mapping (file path → module path)
- [ ] Test with a simple feature module
- [ ] Verify REPL accessibility

### Phase 3: Integration

- [ ] Add home-manager support
- [ ] Add host configurations
- [ ] Test cross-module dependencies
- [ ] Verify enable/disable behavior

### Phase 4: Refinement

- [ ] Add bundle support
- [ ] Improve error messages
- [ ] Add debugging helpers
- [ ] Document patterns and best practices

## Core Concepts

### Namespaces and Auto-Discovery

- Each `_mod.nix` file defines a namespace entry point
- File paths directly map to module paths
- Everything else in the directory is private to that namespace
- No manual imports needed
- Modules do nothing until explicitly enabled

### Enable Flags

- Every module gets an automatic enable flag
- Enable flags follow the namespace structure
- Modules are inert until enabled
- REPL-friendly for inspection before enabling

### Module Organization

Each system type (NixOS, Darwin, Home Manager) follows the same pattern:

```nix
# NixOS modules
modules.nixos.features.desktop.enable = true;
modules.nixos.bundles.server.enable = true;

# Darwin modules
modules.darwin.features.dock.enable = true;
modules.darwin.bundles.workstation.enable = true;

# Home Manager modules
modules.home-manager.features.dev.enable = true;
modules.home-manager.bundles.developer.enable = true;

# Host-specific configurations
modules.hosts.nixos.kamina.enable = true;
modules.hosts.darwin.joyboy.enable = true;
```

### Module Types

#### Features

- Individual, focused pieces of functionality
- Independently enableable
- Located in `features/` under each system type
- Defined by `_mod.nix` in their directory

#### Bundles

- Collections of related features
- Use `mkDefault` to enable features
- Can be overridden by user configuration
- Located in `bundles/` under each system type
- Defined by `_mod.nix` in their directory

#### Hosts

- System-specific configurations
- Can include user-specific settings
- Located in `modules/hosts/{nixos,darwin}`
- Defined by `_mod.nix` in their directory

### Directory Structure

```
modules/
├── nixos/
│   ├── features/          # NixOS-specific features
│   │   ├── desktop/
│   │   │   ├── _mod.nix  # Namespace: modules.nixos.features.desktop
│   │   │   ├── impl.nix  # Private implementation
│   │   │   └── utils.nix # Private utilities
│   │   └── server/
│   │       ├── _mod.nix
│   │       └── impl.nix
│   └── bundles/          # NixOS feature collections
│       ├── desktop/
│       │   ├── _mod.nix
│   │   │   └── impl.nix
│   │   └── server/
│   │       ├── _mod.nix
│   │       └── impl.nix
│   └── darwin/
│       ├── features/         # Darwin-specific features
│       │   ├── dock/
│       │   │   ├── _mod.nix
│       │   │   └── impl.nix
│       │   └── finder/
│       │       ├── _mod.nix
│       │       └── impl.nix
│       └── bundles/         # Darwin feature collections
│           └── workstation/
│               ├── _mod.nix
│               └── impl.nix
├── home-manager/
│   ├── features/        # User-specific features
│   │   ├── desktop/
│   │   │   ├── _mod.nix
│   │   │   └── impl.nix
│   │   ├── gaming/
│   │   │   ├── _mod.nix
│   │   │   └── impl.nix
│   │   └── dev/
│   │       ├── _mod.nix
│   │       └── impl.nix
│   └── bundles/        # User feature collections
│       ├── developer/
│       │   ├── _mod.nix
│       │   └── impl.nix
│       └── gamer/
│           ├── _mod.nix
│           └── impl.nix
└── hosts/              # Host-specific configurations
    ├── nixos/
    │   └── kamina/
    │       ├── _mod.nix
    │       ├── hardware.nix
    │       └── users/
    │           ├── alice/
    │           │   ├── _mod.nix
    │           │   └── impl.nix
    │           └── bob/
    │               ├── _mod.nix
    │               └── impl.nix
    └── darwin/
        └── joyboy/
            ├── _mod.nix
            ├── hardware.nix
            └── users/
                └── alice/
                    ├── _mod.nix
                    └── impl.nix
```
