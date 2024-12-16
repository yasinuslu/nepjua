# Set the default shell to bash for more features
set shell := ["bash", "-uc"]

# Determine the OS and set the appropriate rebuild command
os := `uname`
rebuild_cmd := if os == "Darwin" { "darwin-rebuild" } else { "sudo nixos-rebuild" }
host := `hostname`

# Default recipe to show available commands
default:
  @just --list

# Clean up and optimize the Nix store
gc:
  #!/usr/bin/env bash
  set -euo pipefail
  sudo nix-env -p /nix/var/nix/profiles/system --delete-generations +3
  sudo nix-collect-garbage --delete-older-than 7d
  sudo nix store gc
  sudo nix store optimise

# Open a Nix REPL with trace
repl:
  nix repl --show-trace

# Open a Nix REPL with nixpkgs
repl-nixpkgs:
  nix repl -f flake:nixpkgs

# Build with verbose output and no cache
build-verbose-no-cache:
  #!/usr/bin/env bash
  set -euo pipefail
  echo "Building with verbose output and no cache using {{rebuild_cmd}}..."
  {{rebuild_cmd}} build --flake .#{{host}} --option eval-cache false --show-trace --print-build-logs --verbose --impure

# Build with verbose output
build-verbose:
  #!/usr/bin/env bash
  set -euo pipefail
  echo "Building with verbose output using {{rebuild_cmd}}..."
  {{rebuild_cmd}} build --flake .#{{host}} --show-trace --print-build-logs --verbose --impure

# Switch configuration using the detected rebuild command with retries
switch:
  #!/usr/bin/env bash
  set -euo pipefail
  echo "Switching configuration on {{os}} using {{rebuild_cmd}}..."
  for i in {1..3}; do
      if {{rebuild_cmd}} switch --flake .#{{host}} --impure; then
          echo "Switch successful on attempt $i"
          exit 0
      else
          echo "Switch failed on attempt $i, retrying in 5 seconds..."
          sleep 5
      fi
  done
  echo "Switch failed after 3 attempts"
  exit 1

boot:
  #!/usr/bin/env bash
  set -euo pipefail
  echo "Setting configuration on {{os}} using {{rebuild_cmd}} for next boot..."
  for i in {1..3}; do
      if {{rebuild_cmd}} boot --flake .#{{host}} --impure; then
          echo "Build successful on attempt $i"
          exit 0
      else
          echo "Build failed on attempt $i, retrying in 5 seconds..."
          sleep 5
      fi
  done
  echo "Build failed after 3 attempts"
  exit 1

# Update dconf settings
update-dconf:
    #!/usr/bin/env bash
    set -euo pipefail
    
    # Base directory for dconf settings
    TARGET_DIR="./modules/home-manager/features-linux/gnome/dconf"
    mkdir -p "$TARGET_DIR"
    
    # Array to store successfully generated files
    declare -a generated_files
    
    # Function to process dconf dumps
    process_dconf() {
        local path="$1"
        local output_file="$2"
        local temp_file temp_converted
        temp_file=$(mktemp)
        temp_converted=$(mktemp)
        trap 'rm -f "$temp_file" "$temp_converted"' RETURN
        
        echo "Processing /$path/ -> $output_file"
        
        # Special handling for shell settings
        if [[ "$path" == "org/gnome/shell" ]]; then
            # Only extract simple key-value pairs and arrays
            dconf dump "/$path/" | grep -v "app-picker-layout" > "$temp_file"
        else
            dconf dump "/$path/" > "$temp_file"
        fi
        
        if [ -s "$temp_file" ]; then
            if nix run nixpkgs#dconf2nix -- < "$temp_file" > "$temp_converted"; then
                # Fix the path structure in the generated file
                escaped_path=$(echo "$path" | sed 's/\//\\\//g')
                sed -i "s/\"\" = {/\"$escaped_path\" = {/" "$temp_converted"
                mv "$temp_converted" "$TARGET_DIR/$output_file"
                echo "Generated $output_file"
                generated_files+=("$output_file")
            else
                echo "Failed to convert $output_file"
                return 1
            fi
        else
            echo "No settings found for /$path/"
        fi
    }
    
    # Process each dconf path
    process_dconf "org/gnome/desktop/interface" "interface.nix"
    process_dconf "org/gnome/desktop/input-sources" "input.nix"
    process_dconf "org/gnome/desktop/wm" "wm.nix"
    process_dconf "org/gnome/mutter" "mutter.nix"
    process_dconf "org/gnome/shell" "shell.nix"
    process_dconf "org/gnome/settings-daemon/plugins/power" "power.nix"
    process_dconf "org/gnome/desktop/media-handling" "media.nix"
    process_dconf "org/gnome/desktop/privacy" "privacy.nix"
    process_dconf "org/gnome/desktop/wm/keybindings" "keybindings.nix"
    process_dconf "org/gnome/settings-daemon/plugins/media-keys" "media-keys.nix"
    process_dconf "org/gnome/shell/keybindings" "shell-keybindings.nix"
    process_dconf "org/gnome/desktop/background" "background.nix"
    
    # Generate default.nix only with successfully generated files
    if [ ${#generated_files[@]} -gt 0 ]; then
        {
            echo '{ lib, ... }:'
            echo ''
            echo '{'
            echo '  imports = ['
            for file in "${generated_files[@]}"; do
                echo "    ./$file"
            done
            echo '  ];'
            echo '}'
        } > "$TARGET_DIR/default.nix"
        
        echo "Successfully updated dconf settings in $TARGET_DIR/"
    else
        echo "No dconf settings were generated"
    fi

# Update flake
up:
  nix flake update

# Fetch submodules
sub-fetch:
  git submodule update --init --recursive

# Commit all submodules using heredoc syntax and handle no changes
sub-sync:
  #!/usr/bin/env bash
  git submodule foreach --quiet 'git add . && \
    if ! git diff --cached --quiet; then \
      git commit -m "Auto commit by Justfile" && git push; \
    fi'

  git add git/*
  if ! git diff --cached --quiet; then
    git commit -m "Update submodules"
    git push
  fi
