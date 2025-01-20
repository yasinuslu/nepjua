# Nix Configuration Module System

## Overview

Our module system is built on Nix Flakes and Flake-Parts, providing a powerful,
auto-discovering configuration framework.

## Core Principles

- **Auto-Discovery**: Automatic module detection and importing
- **Modularity**: Small, focused, single-responsibility modules
- **Flexibility**: Easy composition and extension of configurations
- **Reproducibility**: Consistent, predictable system configurations

## Namespaces and Discovery

### Module Path Mapping

File paths directly map to module namespaces:

```
modules/nixos/features/hello.nix → flakeModules.nixos.features.hello
modules/darwin/bundles/dev.nix   → flakeModules.darwin.bundles.dev
```

### Discovery Mechanism

1. Recursively scan `modules/` directory
2. Process each `.nix` file as a potential module
3. Create nested and flat module structures
4. Use `flake-parts-lib.importApply` for module processing

## Module Types

### Features

- Individual, atomic configuration units
- Located in `modules/<system>/features/`
- Single `.nix` file per feature
- Directly expose flake outputs
- No manual enable options

Example:

```nix
{
  flake = {
    # Direct feature configuration
    myFeature = { ... };
  };
}
```

### Bundles

- Collections of related features
- Located in `modules/<system>/bundles/`
- Combine multiple features
- Explicit enabling via `myNixOS.bundles.<name>.enable`

Example:

```nix
{
  flake = {
    # Bundle combining multiple features
    devEnvironment = {
      features = [ "vscode" "git" "terminal" ];
    };
  };
}
```

## Module Structure

Modules can be defined in two primary ways:

1. Direct Module:

```nix
{
  flake = {
    myOutput = "value";
  };
}
```

2. Parameterized Module:

```nix
localFlake: { config, lib, ... }: {
  flake = {
    # Computed outputs based on local flake context
    myOutput = "computed value";
  };
}
```

## REPL Interaction

Verify module discovery and access:

```nix
nix repl
> :lf .#
> flakeModules.nixos.features.hello  # Access specific module
```

## Best Practices

- Keep modules small and focused
- Use meaningful, descriptive names
- Ensure each module has a clear, single responsibility
- Document non-obvious implementation details
- Maintain consistent directory structure
