# Nepjua Nix Configuration

A comprehensive Nix-based system configuration framework for managing multiple
machines across different platforms (NixOS, macOS, and WSL).

## Features

- 🖥️ **Multi-Platform Support**
  - NixOS (Linux) configuration
  - nix-darwin (macOS) configuration
  - NixOS-WSL support
  - Hetzner Cloud deployment

- 🧩 **Modular Design**
  - Reusable configuration modules
  - Platform-specific features
  - User environment management
  - Service configurations

- 🛠️ **Development Tools**
  - Modern shell environments (Fish, Nushell, Zsh)
  - Development utilities
  - Container tools (Docker, Kubernetes)
  - Terminal enhancements

- ⚙️ **System Management**
  - Declarative system configuration
  - Reproducible environments
  - Easy system updates
  - Configuration rollbacks

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

3. Apply configuration based on your system:

### macOS Configuration

```bash
nix run nix-darwin -- switch --flake .#$hostname
```

Replace `$hostname` with one of: `joyboy`, `sezer`, `chained`

### NixOS Configuration

```bash
sudo nixos-rebuild switch --flake .#kaori
```

### NixOS-WSL Configuration

```bash
sudo nixos-rebuild switch --flake .#tristan --impure
```

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

## Nep CLI

The repo includes **`nep`**, a small CLI for automation tasks (SOPS, certs, secrets, etc.). Supported release targets: **Linux x86_64** and **macOS ARM64**. Install prebuilt binaries from [GitHub Releases](https://github.com/yasinuslu/nepjua/releases); full instructions: [docs/cli/README.md](./docs/cli/README.md). Maintainers: [Releasing nep](./docs/development/releasing-nep.md).

## Documentation

Comprehensive documentation is available in the [docs](./docs) directory:

- [Getting Started Guide](./docs/getting-started/README.md)
- [Available Features](./docs/features/README.md)
- [Module System](./docs/modules/README.md)
- [Troubleshooting Guide](./docs/troubleshooting/README.md)
- [Nep CLI](./docs/cli/README.md)

## Common Tasks

### GitHub Rate Limiting

Set up authentication:

```bash
gh auth login
export NIX_CONFIG="extra-access-tokens = github.com=$(gh auth token -u yasinuslu)"
```

## Credits

- Configuration inspiration from
  [vimjoyer/nixconf](https://github.com/vimjoyer/nixconf)
- Structure based on
  [this excellent guide](https://www.youtube.com/watch?v=vYc6IzKvAJQ) by
  @vimjoyer

## FAQ

### How can I run CopyQ on Mac ?

CopyQ have codesigning issues for a very long time. More info in
[this github issue](https://github.com/hluk/CopyQ/issues/2662).

The simplest, easiest solution is to manual signing:

```sh
xattr -rd com.apple.quarantine /Applications/CopyQ.app
codesign -f --deep -s - /Applications/CopyQ.app
```
