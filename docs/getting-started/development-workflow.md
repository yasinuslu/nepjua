# Development Workflow

## REPL-Driven Development

Our configuration system uses a REPL-driven approach to ensure high-quality,
testable configurations.

## Core Principles

1. **REPL First**: Validate every configuration change in the Nix REPL
2. **Testability**: Ensure each module and feature is independently verifiable
3. **Reproducibility**: Maintain consistent, predictable system configurations
4. **Modularity**: Create small, focused, single-responsibility modules

## Workflow Steps

### 1. Start REPL Session

```bash
nix repl
```

### 2. Load Flake

```nix
> :lf .#
```

### 3. Verify Module Discovery

```nix
# Access specific modules
> flakeModules.nixos.features.hello
> flakeModules.darwin.bundles.dev
```

### 4. Test Module Outputs

```nix
# Inspect module outputs
> .#flakeModules.nixos.features.hello.flake
```

## Development Phases

### Phase 1: Module Creation

- Define a new feature or bundle
- Create a `.nix` file in the appropriate directory
- Implement minimal, focused functionality
- Ensure direct flake output exposure

Example:

```nix
# modules/nixos/features/my-feature.nix
{
  flake = {
    myFeature = {
      description = "A new system feature";
      # Configuration details
    };
  };
}
```

### Phase 2: REPL Validation

- Load the flake in REPL
- Verify module discovery
- Check module outputs
- Test module interactions

### Phase 3: Integration

- Combine features into bundles
- Test cross-module dependencies
- Validate enable/disable behavior

### Phase 4: Refinement

- Optimize module performance
- Improve error handling
- Add comprehensive documentation
- Ensure clean, consistent structure

## Best Practices

- Break complex features into testable chunks
- Use descriptive, meaningful module names
- Document non-obvious implementation details
- Maintain a clean, consistent directory structure
- Prioritize module independence and reusability

## Troubleshooting

- Verify module discovery in REPL
- Check flake outputs
- Validate module structure
- Use `nix flake show` for overview
- Leverage `nix repl` for interactive debugging

## Continuous Improvement

- Regularly review and refactor modules
- Keep modules small and focused
- Encourage peer reviews
- Maintain comprehensive REPL tests
