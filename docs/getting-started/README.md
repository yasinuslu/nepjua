# Getting Started

This guide will help you get started with the Nepjua Nix Configuration system.

## Prerequisites

- Nix package manager installed
- Git for cloning the repository
- Basic understanding of Nix/NixOS concepts

## Quick Start

1. Install Nix:
   ```bash
   curl -L https://nixos.org/nix/install | sh
   ```

2. Clone the repository:
   ```bash
   git clone https://github.com/yasinuslu/nepjua.git
   cd nepjua
   ```

3. Choose your system type:

### For macOS (Darwin)

```bash
nix run nix-darwin -- switch --flake .#$hostname
```

Replace `$hostname` with one of: `joyboy`, `sezer`, `chained`

### For NixOS

```bash
sudo nixos-rebuild switch --flake .#kaori
```

## System Types

This configuration supports multiple system types:

- **NixOS Systems**: Full Linux systems running NixOS
- **Darwin Systems**: macOS systems using nix-darwin
- **Home Manager**: User environment configuration (works on both platforms)

## Configuration Structure

The configuration is organized into:

1. **Host Configurations** (`hosts/`):
   - Individual system configurations
   - Platform-specific settings
   - User-specific customizations

2. **Modules** (`modules/`):
   - Reusable configuration components
   - Feature toggles
   - Service definitions

3. **Features**:
   - Shell environments (fish, zsh, nushell)
   - Development tools
   - System utilities
   - UI customizations

## Next Steps

- [Detailed Installation Guide](./installation.md)
- [Configuration Guide](./configuration.md)
- [Available Features](../features/available-features.md)
- [Host Configuration Guide](../hosts/README.md)
