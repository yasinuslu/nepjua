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

- [x] Set up basic flake with flake-parts
- [x] Create minimal directory structure
- [x] Implement basic file discovery (find all .nix files)
- [x] Create a simple test module to verify discovery

### Phase 2: Module System

- [x] Implement basic module wrapping (just the enable flag)
- [x] Create namespace mapping (file path → module path)
- [x] Test with a simple feature module
- [x] Verify REPL accessibility

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

- Each .nix file is a flake-module that is automatically discovered and imported
  at the root of the flake
- Each module is assigned in `flakeModules."${modulePath}"`
- Each module introduces myFlake."${modulePath}".enable flag to enable it
- Each module receives its configuration via `config.myFlake."${modulePath}"`
- Modules can define `options` that are merged into their namespace
- File paths directly map to module paths (e.g.,
  `modules/nixos/features/hello.nix` → `myFlake.nixos.features.hello`)
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
myFlake.nixos.features.desktop.enable = true;
myFlake.nixos.bundles.server.enable = true;

# Darwin modules
myFlake.darwin.features.dock.enable = true;
myFlake.darwin.bundles.workstation.enable = true;

# Home Manager modules
myFlake.home-manager.features.dev.enable = true;
myFlake.home-manager.bundles.developer.enable = true;

# Host-specific configurations
myFlake.hosts.nixos.kamina.enable = true;
myFlake.hosts.darwin.joyboy.enable = true;
```

### Module Types

#### Features

- Individual, focused pieces of functionality
- Independently enableable
- Located in `features/` under each system type
- Each feature is a single .nix file

#### Bundles

- Collections of related features
- Use `mkDefault` to enable features
- Can be overridden by user configuration
- Located in `bundles/` under each system type
- Each bundle is a single .nix file

#### Hosts

- System-specific configurations
- Can include user-specific settings
- Located in `modules/hosts/{nixos,darwin}`
- Each host is a single .nix file

### Directory Structure

```
modules/
├── nixos/
│   ├── features/          # NixOS-specific features
│   │   ├── desktop.nix    # Namespace: myFlake.nixos.features.desktop
│   │   └── server.nix     # Namespace: myFlake.nixos.features.server
│   └── bundles/          # NixOS feature collections
│       ├── desktop.nix    # Namespace: myFlake.nixos.bundles.desktop
│       └── server.nix     # Namespace: myFlake.nixos.bundles.server
├── darwin/
│   ├── features/         # Darwin-specific features
│   │   ├── dock.nix      # Namespace: myFlake.darwin.features.dock
│   │   └── finder.nix    # Namespace: myFlake.darwin.features.finder
│   └── bundles/         # Darwin feature collections
│       └── workstation.nix # Namespace: myFlake.darwin.bundles.workstation
├── home-manager/
│   ├── features/        # User-specific features
│   │   ├── desktop.nix  # Namespace: myFlake.home-manager.features.desktop
│   │   ├── gaming.nix   # Namespace: myFlake.home-manager.features.gaming
│   │   └── dev.nix      # Namespace: myFlake.home-manager.features.dev
│   └── bundles/        # User feature collections
│       ├── developer.nix # Namespace: myFlake.home-manager.bundles.developer
│       └── gamer.nix     # Namespace: myFlake.home-manager.bundles.gamer
└── hosts/              # Host-specific configurations
    ├── nixos/
    │   └── kamina.nix   # Namespace: myFlake.hosts.nixos.kamina
    └── darwin/
        └── joyboy.nix   # Namespace: myFlake.hosts.darwin.joyboy
```
