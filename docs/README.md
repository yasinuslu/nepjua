# Nix Configuration Documentation

Welcome to the documentation for the Nepjua Nix Configuration system. This
documentation explains our modular, auto-discovering Nix configuration
framework.

## Core Concepts

- **Auto-Discovery**: Modules are automatically discovered and imported
- **Flake-Parts**: Leveraging flake-parts for modular configuration
- **REPL-Driven Development**: Testable, verifiable configuration approach

## Documentation Sections

### Getting Started

- [Development Workflow](getting-started/development-workflow.md)
  - REPL-driven development process
  - Module testing and validation

### Module System

- [Module System Overview](modules/module-system.md)
  - Namespaces and auto-discovery
  - Module types (Features, Bundles)
  - Implementation details

### Project Structure

```
.
├── modules/
│   ├── nixos/
│   │   ├── features/    # NixOS-specific features
│   │   └── bundles/     # NixOS feature collections
│   └── darwin/
│       ├── features/    # Darwin-specific features
│       └── bundles/     # Darwin feature collections
└── hosts/               # Host-specific configurations
    ├── nixos/
    └── darwin/
```

## Key Technologies

- Nix Flakes
- Flake-Parts
- NixOS
- nix-darwin
- Home Manager

## Contributing

1. Read the [Development Workflow](getting-started/development-workflow.md)
2. Follow REPL-driven development principles
3. Ensure module testability
4. Maintain clean, focused modules

## Troubleshooting

- Verify module discovery in REPL
- Check flake outputs
- Validate module structure

## Quick Links

- [Development Workflow](getting-started/development-workflow.md)
- [Module System Overview](modules/module-system.md)
