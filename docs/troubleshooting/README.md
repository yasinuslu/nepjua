# Troubleshooting Guide

This guide covers common issues and their solutions when using the Nepjua Nix
Configuration system.

## Common Issues

### Build Failures

#### Nix Store Permission Issues

```bash
error: permission denied while building '/nix/store/...'
```

**Solution**:

1. Check Nix store permissions:
   ```bash
   sudo chown -R root:nixbld /nix/store
   sudo chmod 1775 /nix/store
   ```

2. Verify your user is in the `nixbld` group:
   ```bash
   sudo usermod -a -G nixbld $USER
   ```

#### Flake Evaluation Errors

```bash
error: flake evaluation failed
```

**Solution**:

1. Update flake inputs:
   ```bash
   nix flake update
   ```

2. Check for syntax errors in your configuration
3. Verify all referenced files exist

### Darwin-Specific Issues

#### Homebrew Integration

```bash
error: The Homebrew installation at /opt/homebrew does not exist
```

**Solution**:

1. Install Homebrew:
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

2. Verify Homebrew location matches configuration

#### System Update Failures

```bash
error: builder for '/nix/store/...' failed with exit code 1
```

**Solution**:

1. Clean build:
   ```bash
   nix-store --verify --check-contents
   nix-store --gc
   ```

2. Rebuild with verbose output:
   ```bash
   nix run nix-darwin -- switch --flake .#$hostname --show-trace
   ```

### Home Manager Issues

#### Profile Generation Failures

```bash
error: collision between new and existing profile
```

**Solution**:

1. Remove old generations:
   ```bash
   home-manager generations
   home-manager remove-generations [ID]
   ```

2. Force rebuild:
   ```bash
   home-manager switch --flake .#$USER@$hostname -b backup
   ```

#### Package Conflicts

```bash
error: collision between packages
```

**Solution**:

1. Check for duplicate package declarations
2. Use `pkgs.hiPrio` for priority packages
3. Review package overlays

## System Recovery

### Emergency Recovery

If your system becomes unbootable:

1. Boot from recovery mode
2. Mount system partitions
3. Rebuild using previous generation:
   ```bash
   nixos-rebuild switch --rollback
   ```

### Configuration Backup

Always keep a backup of working configurations:

1. Use Git branches for experiments
2. Test changes in a VM first
3. Keep known-good generations

## Debugging Tips

### Nix Debugging

1. Enable trace output:
   ```bash
   --show-trace
   ```

2. Debug builds:
   ```bash
   nix-build -K
   ```

3. Check derivation:
   ```bash
   nix show-derivation
   ```

### System Debugging

1. Check system logs:
   ```bash
   journalctl -xe
   ```

2. View service status:
   ```bash
   systemctl status service-name
   ```

3. Check configuration:
   ```bash
   darwin-rebuild check
   nixos-rebuild dry-build
   ```

## FAQ

### Q: How do I avoid GitHub rate limiting?

A: Set up GitHub authentication:

```bash
gh auth login
export NIX_CONFIG="extra-access-tokens = github.com=$(gh auth token -u yasinuslu)"
```

### Q: How do I update all packages?

A: Update flake inputs and rebuild:

```bash
nix flake update
nixos-rebuild switch --flake .#$hostname  # For NixOS
nix run nix-darwin -- switch --flake .#$hostname  # For Darwin
```

### Q: How do I clean up old generations?

A: Use the appropriate command for your system:

```bash
sudo nix-collect-garbage -d  # System-wide
home-manager expire-generations "-30 days"  # Home Manager
```

## Getting Help

If you're still experiencing issues:

1. Check the [GitHub Issues](https://github.com/yasinuslu/nepjua/issues)
2. Review the [Documentation](../README.md)
3. File a new issue with:
   - System information
   - Error messages
   - Steps to reproduce
   - Configuration files
