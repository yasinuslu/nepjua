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
# 1. Test module discovery
nix repl
> :lf .#
> flakeModules.nixos.features.hello  # Access nested structure
```

### Phase 1: Basic Structure

- [x] Set up basic flake with flake-parts
- [x] Create minimal directory structure
- [x] Implement basic file discovery (find all .nix files)
- [x] Create a simple test module to verify discovery

### Phase 2: Module System

- [x] Implement module discovery using flake-parts
- [x] Create namespace mapping (file path → module path)
- [x] Test with a simple feature module
- [x] Verify REPL accessibility
- [x] Support module flake outputs
- [x] Implement nested module structure
- [x] Add automatic module importing

### Phase 3: Integration

- [ ] Add home-manager support
- [ ] Add host configurations
- [x] Test cross-module dependencies
- [ ] Verify enable/disable behavior

### Phase 4: Refinement

- [ ] Add bundle support
- [ ] Improve error messages
- [ ] Add debugging helpers
- [ ] Document patterns and best practices

## Core Concepts

### Namespaces and Auto-Discovery

- Each .nix file is a flake-module that is automatically discovered and imported
- Modules are processed using `flake-parts-lib.importApply`
- File paths directly map to module paths (e.g.,
  `modules/nixos/features/hello.nix` → `nixos.features.hello`)
- No manual imports needed - modules are automatically imported via the flat
  structure
- Modules can be accessed via both nested and flat structures
- The nested structure (`flakeModules`) provides organized navigation
- The flat structure is used for automatic importing

### Module Structure

Each module can be either:

1. A direct flake module:

```nix
{
  flake = {
    # Direct flake outputs
    myOutput = "value";
  };
}
```

2. A function that returns a flake module:

```nix
localFlake: { config, lib, ... }: {
  flake = {
    # Computed flake outputs
    myOutput = "value";
  };
}
```

### Module Organization

Each system type (NixOS, Darwin, Home Manager) follows the same pattern:

```nix
# NixOS modules
modules/
├── nixos/
│   ├── features/          # NixOS-specific features
│   │   ├── desktop.nix    # Available as: flakeModules.nixos.features.desktop
│   │   └── server.nix     # Available as: flakeModules.nixos.features.server
│   └── bundles/          # NixOS feature collections
│       ├── desktop.nix    # Available as: flakeModules.nixos.bundles.desktop
│       └── server.nix     # Available as: flakeModules.nixos.bundles.server
```

### Module Types

#### Features

- Individual, focused pieces of functionality
- Can expose flake outputs directly
- Located in `features/` under each system type
- Each feature is a single .nix file
- Automatically imported and available in the nested structure

#### Bundles

- Collections of related features
- Can expose combined flake outputs
- Located in `bundles/` under each system type
- Each bundle is a single .nix file
- Automatically imported and available in the nested structure

### Directory Structure

```
modules/
├── nixos/
│   ├── features/          # NixOS-specific features
│   │   ├── desktop.nix    # Example: { flake.desktop = "here"; }
│   │   └── server.nix     # Example: { flake.server = "running"; }
│   └── bundles/          # NixOS feature collections
├── darwin/
│   ├── features/         # Darwin-specific features
│   └── bundles/         # Darwin feature collections
└── hosts/              # Host-specific configurations
    ├── nixos/
    └── darwin/
```

### Implementation Details

The module discovery system:

1. Recursively finds all `.nix` files in the modules directory
2. Creates both nested and flat structures:
   - Nested: Mirrors directory hierarchy for organization
   - Flat: Array of modules for automatic importing
3. Uses `flake-parts-lib.importApply` to process each module
4. Automatically imports all modules via the flat structure
5. Exposes the nested structure via `flakeModules`

Example usage in flake:

```nix
let
  allModules = myLib.discoverModules {
    baseDir = ./modules;
    topModuleArgs = moduleArgs;
  };
in
{
  # Automatic importing
  imports = [
    inputs.flake-root.flakeModule
    inputs.treefmt-nix.flakeModule
  ] ++ allModules.flat;

  # Nested structure for organization
  flake.flakeModules = allModules.nested;
}
```

Access in REPL:

```nix
nix repl
> :lf .#
> flakeModules.nixos.features.hello  # Access nested structure
```
