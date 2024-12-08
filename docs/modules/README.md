# Modules

This documentation covers the modular configuration system used in the Nepjua
Nix Configuration.

## Module Types

### NixOS Modules (`modules/nixos/`)

NixOS-specific system configurations:

- **Features**:
  - Base system configuration
  - Service management
  - Hardware configuration
  - Network setup

- **Bundles**:
  - Pre-configured feature sets
  - System role definitions

- **Services**:
  - System service configurations
  - Service dependencies

### Darwin Modules (`modules/darwin/`)

macOS-specific system configurations:

- **Features**:
  - `homebrew-minimal.nix`: Basic Homebrew setup
  - `homebrew-extra.nix`: Additional Homebrew packages
  - `keyboard.nix`: Keyboard customization
  - `alt-tab.nix`: Window switching behavior
  - `base.nix`: Basic system configuration
  - `nix-index.nix`: Nix command-not-found database
  - `home-manager.nix`: Home Manager integration

- **Bundles**:
  - `darwin-desktop.nix`: Complete desktop environment setup

### Home Manager Modules (`modules/home-manager/`)

User environment configurations:

- **Cross-Platform Features** (`features/`):
  - Shell configurations (fish, zsh, nushell)
  - Development tools (git, deno, kubernetes)
  - Terminal utilities (tmux, fzf, bat)
  - Editor configurations

- **Linux-Specific Features** (`features-linux/`):
  - Linux-specific user configurations

- **Darwin-Specific Features** (`features-darwin/`):
  - macOS-specific user configurations

## Module Structure

Each module follows a consistent structure:

```nix
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.myModule;
in {
  options.myModule = {
    enable = mkEnableOption "my module";
    # Additional options...
  };

  config = mkIf cfg.enable {
    # Module implementation...
  };
}
```

## Using Modules

### Enabling Features

In your host configuration:

```nix
{
  myDarwin = {
    bundles.darwin-desktop.enable = true;
    
    users.nepjua = {
      userConfig = {...}: {
        programs.git.userName = "Yasin Uslu";
        myHomeManager.deno.enable = true;
      };
    };
  };
}
```

### Creating Custom Bundles

Bundle multiple features together:

```nix
{ config, lib, ... }:

with lib;

{
  options.myBundle = {
    enable = mkEnableOption "my bundle";
  };

  config = mkIf config.myBundle.enable {
    myFeature1.enable = true;
    myFeature2.enable = true;
    # Additional configuration...
  };
}
```

## Best Practices

1. **Modularity**:
   - Keep modules focused and single-purpose
   - Use options to make modules configurable
   - Separate platform-specific code

2. **Dependencies**:
   - Clearly define module dependencies
   - Use `mkIf` for conditional configuration
   - Handle dependencies gracefully

3. **Documentation**:
   - Document module options
   - Include usage examples
   - Explain non-obvious configurations

4. **Testing**:
   - Test modules in isolation
   - Verify module combinations
   - Check for conflicts

## See Also

- [Feature Documentation](../features/README.md)
- [Host Configuration Guide](../hosts/README.md)
- [Development Guide](../development/README.md)
