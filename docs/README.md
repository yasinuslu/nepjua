# Nepjua Nix Configuration Documentation

Welcome to the documentation for the Nepjua Nix Configuration system. This
documentation will help you understand, use, and contribute to this Nix-based
system configuration framework.

## Documentation Structure

- [Getting Started](./getting-started/README.md)
  - Installation and basic setup
  - Quick start guides
  - System requirements

- [Architecture](./architecture/README.md)
  - System overview
  - Design principles
  - Module structure

- [Modules](./modules/README.md)
  - NixOS modules
  - Darwin modules
  - Home Manager modules
  - Feature modules
  - Bundle configurations

- [Host Configurations](./hosts/README.md)
  - Host setup guides
  - Platform-specific configurations
  - Example configurations

- [Features](./features/README.md)
  - Available features
  - Feature configuration
  - Platform-specific features

- [Development](./development/README.md)
  - Development environment
  - Contributing guidelines
  - Best practices

- [Troubleshooting](./troubleshooting/README.md)
  - Common issues
  - Debugging guides
  - FAQ

## Quick Links

- [Installation Guide](./getting-started/installation.md)
- [Configuration Guide](./getting-started/configuration.md)
- [Feature List](./features/available-features.md)
- [Contributing Guide](./development/contributing.md)

## Repository Structure

```
.
├── flake.nix           # Main entry point
├── hosts/              # Host-specific configurations
├── modules/            # Modular configuration components
│   ├── darwin/         # macOS-specific modules
│   ├── nixos/          # NixOS-specific modules
│   └── home-manager/   # User environment modules
├── my-lib/             # Custom Nix functions
└── docs/               # Documentation
```

## Getting Help

- Check the [Troubleshooting Guide](./troubleshooting/README.md)
- Review the [FAQ](./troubleshooting/faq.md)
- File an issue on the repository
