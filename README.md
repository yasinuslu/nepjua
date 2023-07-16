# Nepjua Nix Config

## MacOS Configuration

### Requirements

1. [Install Nix](https://zero-to-nix.com/start/install)
2. [Install Nix Darwin](https://github.com/LnL7/nix-darwin)
3. Make sure you follow both of the above guides to completion

### Applying Configuration

Execute this every time you make a change to the configuration

```sh
darwin-rebuild switch --flake .#raiden
```

### NixOS Configuration

Install the system

```sh
sudo nixos-rebuild switch --flake .#kaori
```
