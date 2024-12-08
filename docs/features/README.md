# Features

This documentation covers all available features in the Nepjua Nix Configuration
system.

## Cross-Platform Features

### Shell Environments

#### Fish Shell (`features/fish.nix`)

- Modern shell with great defaults
- Custom prompt configuration
- Aliases and functions
- Integration with other tools

#### Nushell (`features/nushell.nix`)

- Modern shell with structured data support
- Custom configuration

#### Zsh (`features/zsh.nix`)

- Traditional shell with modern features
- Custom configuration

### Development Tools

#### Git (`features/git.nix`)

- Git configuration
- Aliases and helpers
- User-specific settings

#### Deno (`features/deno.nix`)

- Deno runtime setup
- Development environment

#### Docker (`features/docker.nix`)

- Container runtime
- Development tools

#### Kubernetes (`features/kubernetes.nix`)

- Kubernetes tools
- Cluster management utilities

### Terminal Utilities

#### Tmux (`features/tmux.nix`)

- Terminal multiplexer
- Custom key bindings
- Session management

#### FZF (`features/fzf.nix`)

- Fuzzy finder
- Shell integration
- Custom keybindings

#### Bat (`features/bat.nix`)

- Modern cat replacement
- Syntax highlighting
- Git integration

## Darwin-Specific Features

### System Configuration

#### Homebrew

- `homebrew-minimal.nix`: Essential packages
- `homebrew-extra.nix`: Additional tools

#### Keyboard (`keyboard.nix`)

- Key remapping
- Modifier keys
- Special functions

#### Window Management

- `alt-tab.nix`: Window switching behavior
- Window management utilities

### System Integration

#### Base System (`base.nix`)

- System defaults
- Security settings
- Performance tuning

#### Nix Integration

- `nix-index.nix`: Command-not-found database
- Package management helpers

## Linux-Specific Features

### System Configuration

- Base system setup
- Service management
- Hardware configuration

### Desktop Environment

- Window manager setup
- Desktop utilities
- System tray

## Feature Configuration

### Enabling Features

Features can be enabled in host configurations:

```nix
{
  myHomeManager = {
    fish.enable = true;
    git.enable = true;
    tmux.enable = true;
  };
}
```

### Common Options

Most features follow a common pattern:

```nix
{
  enable = true;  # Enable the feature
  package = pkgs.somePackage;  # Override default package
  extraConfig = {};  # Additional configuration
}
```

### Feature Dependencies

Some features have dependencies on other features or system components:

- Shell features may depend on core utilities
- Development tools may require specific runtime environments
- System features may need specific hardware support

## Best Practices

1. **Feature Selection**:
   - Enable only needed features
   - Consider dependencies
   - Check platform compatibility

2. **Configuration**:
   - Use feature options for customization
   - Override defaults when necessary
   - Document custom configurations

3. **Testing**:
   - Test feature combinations
   - Verify platform compatibility
   - Check for conflicts

## See Also

- [Module System](../modules/README.md)
- [Host Configuration](../hosts/README.md)
- [Development Guide](../development/README.md)
